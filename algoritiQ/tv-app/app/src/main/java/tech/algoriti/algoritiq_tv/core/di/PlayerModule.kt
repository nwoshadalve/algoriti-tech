/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import tech.algoriti.algoritiq_tv.features.announcement.data.ExoAnnouncementPlayer
import tech.algoriti.algoritiq_tv.features.announcement.domain.AnnouncementPlayer
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class PlayerModule {
    @Binds
    @Singleton
    abstract fun bindAnnouncementPlayer(impl: ExoAnnouncementPlayer): AnnouncementPlayer
}
