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

package org.gradle.caching.internal.tasks;

import org.gradle.api.NonNullApi;
import org.gradle.api.internal.changedetection.state.ImplementationSnapshot;
import org.gradle.api.logging.Logger;
import org.gradle.api.logging.Logging;
import org.gradle.internal.hash.HashCode;

import javax.annotation.Nullable;
import java.util.Collection;

@NonNullApi
public class DebuggingTaskOutputCachingBuildCacheKeyBuilder implements TaskOutputCachingBuildCacheKeyBuilder {
    private static final Logger LOGGER = Logging.getLogger(DebuggingTaskOutputCachingBuildCacheKeyBuilder.class);

    private final TaskOutputCachingBuildCacheKeyBuilder delegate;

    public DebuggingTaskOutputCachingBuildCacheKeyBuilder(TaskOutputCachingBuildCacheKeyBuilder delegate) {
        this.delegate = delegate;
    }

    @Override
    public void appendTaskImplementation(ImplementationSnapshot taskImplementation) {
        log("taskClass", taskImplementation.getTypeName());
        if (!taskImplementation.hasUnknownClassLoader()) {
            log("classLoaderHash", taskImplementation.getClassLoaderHash());
        }
        delegate.appendTaskImplementation(taskImplementation);
    }

    @Override
    public void appendTaskActionImplementations(Collection<ImplementationSnapshot> taskActionImplementations) {
        for (ImplementationSnapshot actionImpl : taskActionImplementations) {
            log("actionType", actionImpl.getTypeName());
            log("actionClassLoaderHash", actionImpl.hasUnknownClassLoader() ? null : actionImpl.getClassLoaderHash());
        }
        delegate.appendTaskActionImplementations(taskActionImplementations);
    }

    @Override
    public void appendInputPropertyHash(String propertyName, HashCode hashCode) {
        LOGGER.lifecycle("Appending inputPropertyHash for '{}' to build cache key: {}", propertyName, hashCode);
        delegate.appendInputPropertyHash(propertyName, hashCode);
    }

    @Override
    public void inputPropertyLoadedByUnknownClassLoader(String propertyName) {
        String sanitizedPropertyName = DefaultTaskOutputCachingBuildCacheKeyBuilder.sanitizeImplementationPropertyName(propertyName);
        LOGGER.lifecycle("The implementation of '{}' cannot be determined, because it was loaded by an unknown classloader", sanitizedPropertyName);
        delegate.inputPropertyLoadedByUnknownClassLoader(propertyName);
    }

    @Override
    public void appendOutputPropertyName(String propertyName) {
        log("outputPropertyName", propertyName);
        delegate.appendOutputPropertyName(propertyName);
    }

    @Override
    public TaskOutputCachingBuildCacheKey build() {
        return delegate.build();
    }

    private void log(String name, @Nullable Object value) {
        LOGGER.lifecycle("Appending {} to build cache key: {}", name, value);
    }

}
