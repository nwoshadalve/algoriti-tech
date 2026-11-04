/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton
import tech.algoriti.algoritiq_tv.features.sync.data.LiveSessionClient
import tech.algoriti.algoritiq_tv.features.sync.data.LiveSessionClientImpl
import tech.algoriti.algoritiq_tv.features.sync.data.LiveSessionRepositoryImpl
import tech.algoriti.algoritiq_tv.features.sync.domain.LiveSessionRepository

@Module
@InstallIn(SingletonComponent::class)
abstract class SyncModule {
    @Binds
    @Singleton
    abstract fun bindLiveSessionClient(impl: LiveSessionClientImpl): LiveSessionClient

    @Binds
    @Singleton
    abstract fun bindLiveSessionRepository(impl: LiveSessionRepositoryImpl): LiveSessionRepository
}
