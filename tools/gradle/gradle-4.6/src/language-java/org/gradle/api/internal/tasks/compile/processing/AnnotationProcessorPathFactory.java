/*
 * Copyright 2018 the original author or authors.
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

package org.gradle.api.internal.tasks.compile.processing;

import com.google.common.base.Joiner;
import com.google.common.base.Splitter;
import org.gradle.api.InvalidUserDataException;
import org.gradle.api.file.FileCollection;
import org.gradle.api.internal.file.FileCollectionFactory;
import org.gradle.api.internal.file.collections.MinimalFileSet;
import org.gradle.api.internal.tasks.AbstractTaskDependency;
import org.gradle.api.internal.tasks.TaskDependencyResolveContext;
import org.gradle.api.tasks.compile.CompileOptions;
import org.gradle.util.DeprecationLogger;

import java.io.File;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;


public class AnnotationProcessorPathFactory {
    public static final String COMPILE_CLASSPATH_DEPRECATION_MESSAGE = "Putting annotation processors on the compile classpath";
    public static final String PROCESSOR_PATH_DEPRECATION_MESSAGE = "Specifying the processor path in the CompilerOptions compilerArgs property";

    private final FileCollectionFactory fileCollectionFactory;
    private final AnnotationProcessorDetector annotationProcessorDetector;

    public AnnotationProcessorPathFactory(FileCollectionFactory fileCollectionFactory, AnnotationProcessorDetector annotationProcessorDetector) {
        this.fileCollectionFactory = fileCollectionFactory;
        this.annotationProcessorDetector = annotationProcessorDetector;
    }

    /**
     * Calculates the annotation processor path to use given some compile options and compile classpath.
     *
     * For backwards compatibility we still support the -processorpath option and we also look for processors
     * on the compile classpath if the processor path was an empty {@link DefaultProcessorPath}. In Gradle 5.0 we will ignore
     * -processorpath and the compile classpath. We will then use the annotationProcessorPath as the single source of truth.
     *
     * @return An empty collection when annotation processing should not be performed, non-empty when it should.
     */
    public FileCollection getEffectiveAnnotationProcessorClasspath(final CompileOptions compileOptions, final FileCollection compileClasspath) {
        if (compileOptions.getCompilerArgs().contains("-proc:none")) {
            return fileCollectionFactory.empty("annotation processor path");
        }
        final FileCollection annotationProcessorPath = compileOptions.getAnnotationProcessorPath();
        if (annotationProcessorPath != null && !(annotationProcessorPath instanceof DefaultProcessorPath)) {
            return annotationProcessorPath;
        }
        FileCollection processorPathFromCompilerArguments = getProcessorPathFromCompilerArguments(compileOptions);
        if (processorPathFromCompilerArguments != null) {
            return processorPathFromCompilerArguments;
        }
        if (compileClasspath == null) {
            return annotationProcessorPath;
        }
        return getProcessorPathWithCompileClasspathFallback(compileOptions, compileClasspath, annotationProcessorPath);
    }

    private FileCollection getProcessorPathFromCompilerArguments(final CompileOptions compileOptions) {
        final FileCollection annotationProcessorPath = compileOptions.getAnnotationProcessorPath();
        int pos = compileOptions.getCompilerArgs().indexOf("-processorpath");
        if (pos < 0) {
            return null;
        }
        if (pos == compileOptions.getCompilerArgs().size() - 1) {
            throw new InvalidUserDataException("No path provided for compiler argument -processorpath in requested compiler args: " + Joiner.on(" ").join(compileOptions.getCompilerArgs()));
        }
        final String processorpath = compileOptions.getCompilerArgs().get(pos + 1);
        if (annotationProcessorPath == null) {
            return fileCollectionFactory.fixed("annotation processor path", extractProcessorPath(processorpath));
        }
        return fileCollectionFactory.create(
            new AbstractTaskDependency() {
                @Override
                public void visitDependencies(TaskDependencyResolveContext context) {
                    context.add(annotationProcessorPath);
                }
            },
            new MinimalFileSet() {
                @Override
                public Set<File> getFiles() {
                    if (!annotationProcessorPath.isEmpty()) {
                        return annotationProcessorPath.getFiles();
                    }
                    return extractProcessorPath(processorpath);
                }

                @Override
                public final String getDisplayName() {
                    return "annotation processor path";
                }
            });
    }

    private static Set<File> extractProcessorPath(String processorpath) {
        DeprecationLogger.nagUserOfDeprecated(
            PROCESSOR_PATH_DEPRECATION_MESSAGE,
            "Instead, use the CompilerOptions.annotationProcessorPath property directly");
        LinkedHashSet<File> files = new LinkedHashSet<File>();
        for (String path : Splitter.on(File.pathSeparatorChar).splitToList(processorpath)) {
            files.add(new File(path));
        }
        return files;
    }

    private FileCollection getProcessorPathWithCompileClasspathFallback(CompileOptions compileOptions, final FileCollection compileClasspath, final FileCollection annotationProcessorPath) {
        final boolean hasExplicitProcessor = checkExplicitProcessorOption(compileOptions);
        return fileCollectionFactory.create(
            new AbstractTaskDependency() {
                @Override
                public void visitDependencies(TaskDependencyResolveContext context) {
                    if (annotationProcessorPath != null) {
                        context.add(annotationProcessorPath);
                    }
                    context.add(compileClasspath);
                }
            },
            new MinimalFileSet() {
                @Override
                public Set<File> getFiles() {
                    if (annotationProcessorPath != null && !annotationProcessorPath.isEmpty()) {
                        return annotationProcessorPath.getFiles();
                    }
                    if (hasExplicitProcessor) {
                        return compileClasspath.getFiles();
                    }
                    if (!annotationProcessorDetector.detectProcessors(compileClasspath).isEmpty()) {
                        DeprecationLogger.nagUserOfDeprecated(COMPILE_CLASSPATH_DEPRECATION_MESSAGE, "Please add them to the processor path instead. If these processors were unintentionally leaked on the compile classpath, use the -proc:none compiler option to ignore them.");
                        return compileClasspath.getFiles();
                    }
                    return Collections.emptySet();
                }

                @Override
                public final String getDisplayName() {
                    return "annotation processor path";
                }
            });
    }

    private static boolean checkExplicitProcessorOption(CompileOptions compileOptions) {
        boolean hasExplicitProcessor = false;
        int pos = compileOptions.getCompilerArgs().indexOf("-processor");
        if (pos >= 0) {
            if (pos == compileOptions.getCompilerArgs().size() - 1) {
                throw new InvalidUserDataException("No processor specified for compiler argument -processor in requested compiler args: " + Joiner.on(" ").join(compileOptions.getCompilerArgs()));
            }
            hasExplicitProcessor = true;
        }
        return hasExplicitProcessor;
    }
}
