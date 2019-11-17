/*
 * Copyright 2017 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.gradle.vcs.git.internal;

import com.google.common.collect.Sets;
import org.eclipse.jgit.api.CloneCommand;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.ResetCommand;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.api.errors.JGitInternalException;
import org.eclipse.jgit.lib.Config;
import org.eclipse.jgit.lib.Ref;
import org.eclipse.jgit.lib.Repository;
import org.eclipse.jgit.submodule.SubmoduleWalk;
import org.eclipse.jgit.transport.URIish;
import org.gradle.api.GradleException;
import org.gradle.api.logging.Logger;
import org.gradle.api.logging.Logging;
import org.gradle.vcs.VersionControlSpec;
import org.gradle.vcs.git.GitVersionControlSpec;
import org.gradle.vcs.internal.VersionControlSystem;
import org.gradle.vcs.internal.VersionRef;

import javax.annotation.Nullable;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * A Git {@link VersionControlSystem} implementation.
 */
public class GitVersionControlSystem implements VersionControlSystem {

    private static final Logger LOGGER = Logging.getLogger(GitVersionControlSystem.class);

    @Override
    public File populate(File versionDir, VersionRef ref, VersionControlSpec spec) {
        GitVersionControlSpec gitSpec = cast(spec);
        File workingDir = new File(versionDir, gitSpec.getRepoName());

        File dbDir = new File(workingDir, ".git");

        LOGGER.info("Populating VCS workingDir {}/{} with ref {}", versionDir.getName(), workingDir.getName(), ref);

        if (dbDir.exists() && dbDir.isDirectory()) {
            updateRepo(workingDir, gitSpec, ref);
        } else {
            cloneRepo(workingDir, gitSpec, ref);
        }
        return workingDir;
    }

    @Override
    public Set<VersionRef> getAvailableVersions(VersionControlSpec spec) {
        GitVersionControlSpec gitSpec = cast(spec);
        Collection<Ref> refs;
        try {
            refs = Git.lsRemoteRepository().setRemote(normalizeUri(gitSpec.getUrl())).setTags(true).setHeads(false).call();
        } catch (URISyntaxException e) {
            throw wrapGitCommandException("ls-remote", gitSpec.getUrl(), null, e);
        } catch (GitAPIException e) {
            throw wrapGitCommandException("ls-remote", gitSpec.getUrl(), null, e);
        }
        Set<VersionRef> versions = Sets.newHashSet();
        for (Ref ref : refs) {
            GitVersionRef gitRef = GitVersionRef.from(ref);
            versions.add(gitRef);
        }
        return versions;
    }

    @Override
    public VersionRef getDefaultBranch(VersionControlSpec spec) {
        GitVersionControlSpec gitSpec = cast(spec);
        Collection<Ref> refs;
        try {
            refs = Git.lsRemoteRepository().setRemote(normalizeUri(gitSpec.getUrl())).setTags(false).call();
        } catch (URISyntaxException e) {
            throw wrapGitCommandException("ls-remote", gitSpec.getUrl(), null, e);
        } catch (GitAPIException e) {
            throw wrapGitCommandException("ls-remote", gitSpec.getUrl(), null, e);
        }
        for (Ref ref : refs) {
            if (ref.getName().equals("refs/heads/master")) {
                return GitVersionRef.from(ref);
            }
        }
        throw new UnsupportedOperationException("Git repository has no master branch");
    }

    @Nullable
    @Override
    public VersionRef getBranch(VersionControlSpec spec, String branch) {
        GitVersionControlSpec gitSpec = cast(spec);
        Collection<Ref> refs;
        try {
            refs = Git.lsRemoteRepository().setRemote(normalizeUri(gitSpec.getUrl())).setHeads(true).setTags(false).call();
        } catch (URISyntaxException e) {
            throw wrapGitCommandException("ls-remote", gitSpec.getUrl(), null, e);
        } catch (GitAPIException e) {
            throw wrapGitCommandException("ls-remote", gitSpec.getUrl(), null, e);
        }
        String refName = "refs/heads/" + branch;
        for (Ref ref : refs) {
            if (ref.getName().equals(refName)) {
                return GitVersionRef.from(ref);
            }
        }
        return null;
    }

    private static void cloneRepo(File workingDir, GitVersionControlSpec gitSpec, VersionRef ref) {
        CloneCommand clone = Git.cloneRepository().
            setURI(gitSpec.getUrl().toString()).
            setDirectory(workingDir).
            setCloneSubmodules(true);
        Git git = null;
        try {
            git = clone.call();
            git.reset().setMode(ResetCommand.ResetType.HARD).setRef(ref.getCanonicalId()).call();
        } catch (GitAPIException e) {
            throw wrapGitCommandException("clone", gitSpec.getUrl(), workingDir, e);
        } catch (JGitInternalException e) {
            throw wrapGitCommandException("clone", gitSpec.getUrl(), workingDir, e);
        } finally {
            if (git != null) {
                git.close();
            }
        }
    }

    private static void updateRepo(File workingDir, GitVersionControlSpec gitSpec, VersionRef ref) {
        Git git = null;
        try {
            git = Git.open(workingDir);
            git.fetch().setRemote(getRemoteForUrl(git.getRepository(), gitSpec.getUrl())).call();
            git.reset().setMode(ResetCommand.ResetType.HARD).setRef(ref.getCanonicalId()).call();
            updateSubModules(git);
        } catch (IOException e) {
            throw wrapGitCommandException("update", gitSpec.getUrl(), workingDir, e);
        } catch (URISyntaxException e) {
            throw wrapGitCommandException("update", gitSpec.getUrl(), workingDir, e);
        } catch (GitAPIException e) {
            throw wrapGitCommandException("update", gitSpec.getUrl(), workingDir, e);
        } catch (JGitInternalException e) {
            throw wrapGitCommandException("update", gitSpec.getUrl(), workingDir, e);
        } finally {
            if (git != null) {
                git.close();
            }
        }
    }

    private static void updateSubModules(Git git) throws IOException, GitAPIException {
        SubmoduleWalk walker = SubmoduleWalk.forIndex(git.getRepository());
        try {
            while (walker.next()) {
                Repository submodule = walker.getRepository();
                try {
                    Git submoduleGit = Git.wrap(submodule);
                    submoduleGit.fetch().call();
                    git.submoduleUpdate().addPath(walker.getPath()).call();
                    submoduleGit.reset().setMode(ResetCommand.ResetType.HARD).call();
                    updateSubModules(submoduleGit);
                } finally {
                    submodule.close();
                }
            }
        } finally {
            walker.close();
        }
    }

    // This method is only necessary until https://bugs.eclipse.org/bugs/show_bug.cgi?id=525300 is fixed.
    private static String getRemoteForUrl(Repository repository, URI url) throws URISyntaxException {
        Config config = repository.getConfig();
        Set<String> remotes = config.getSubsections("remote");
        Set<String> foundUrls = new HashSet<String>();
        String normalizedUrl = normalizeUri(url);

        for (String remote : remotes) {
            String remoteUrl = config.getString("remote", remote, "url");
            if (remoteUrl.equals(normalizedUrl)) {
                return remote;
            } else {
                foundUrls.add(remoteUrl);
            }
        }
        throw new GradleException(String.format("Could not find remote with url: %s. Found: %s", url, foundUrls));
    }

    private static String normalizeUri(URI uri) throws URISyntaxException {
        // We have to go through URIish and back to deal with differences between how
        // Java File and Git implement file URIs.
        return new URIish(uri.toString()).toString();
    }

    private static GitVersionControlSpec cast(VersionControlSpec spec) {
        if (!(spec instanceof GitVersionControlSpec)) {
            throw new IllegalArgumentException("The GitVersionControlSystem can only handle GitVersionControlSpec instances.");
        }
        return (GitVersionControlSpec) spec;
    }

    private static GradleException wrapGitCommandException(String commandName, URI repoUrl, File workingDir, Exception e) {
        if (workingDir == null) {
            return new GradleException(String.format("Could not run %s for %s", commandName, repoUrl), e);
        }
        return new GradleException(String.format("Could not %s from %s in %s", commandName, repoUrl, workingDir), e);
    }
}
