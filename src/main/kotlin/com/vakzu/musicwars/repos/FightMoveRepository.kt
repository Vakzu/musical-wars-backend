package com.vakzu.musicwars.repos

import com.vakzu.musicwars.entities.FightMove

interface FightMoveRepository {

    fun playFight(characterIds: Collection<Int>,
                  effectIds: Collection<Int>,
                  songIds: Collection<Int>,
                  locationId: Int): List<FightMove>

}