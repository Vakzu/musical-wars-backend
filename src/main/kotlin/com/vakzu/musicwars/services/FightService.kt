package com.vakzu.musicwars.services

import com.vakzu.musicwars.entities.FightMove
import com.vakzu.musicwars.lobby.Lobby
import com.vakzu.musicwars.repos.FightMoveRepository
import org.springframework.stereotype.Service

@Service
class FightService(private val fightMoveRepository: FightMoveRepository) {

    fun playFight(lobby: Lobby): List<FightMove> {
        val characterIds = lobby.participants.values.map { it.characterId }
        val effectIds = lobby.participants.values.map { it.effectId }
        val songIds = lobby.participants.values.map { it.songId }
        val locationId = lobby.locationId
        return fightMoveRepository.playFight(characterIds, effectIds, songIds, locationId)
    }



}