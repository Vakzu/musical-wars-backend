package com.vakzu.musicwars.services

import com.vakzu.musicwars.entities.FightMove
import com.vakzu.musicwars.repos.FightMoveRepository
import org.springframework.stereotype.Repository
import java.sql.Connection
import javax.sql.DataSource

@Repository
class FightMoveDao(dataSource: DataSource): FightMoveRepository {

    private val connection: Connection = dataSource.connection

    override fun playFight(characterIds: Collection<Int>,
                  effectIds: Collection<Int>,
                   songIds: Collection<Int>,
                  locationId: Int): List<FightMove> {

        val statement = connection.prepareCall("{call begin_fight(?, ?, ?, ?)}")
        statement.setArray(1, connection.createArrayOf("int", characterIds.toTypedArray()))
        statement.setArray(2, connection.createArrayOf("int", effectIds.toTypedArray()))
        statement.setArray(3, connection.createArrayOf("int", songIds.toTypedArray()))
        statement.setInt(4, locationId)

        val resultSet = statement.executeQuery()
        val result = ArrayList<FightMove>()

        while (resultSet.next()) {
            val fightMove = FightMove()
            fightMove.moveNumber = resultSet.getInt("move_number")
            fightMove.attackerId = resultSet.getInt("attacker_id")
            fightMove.fightId = resultSet.getInt("fight_id")
            fightMove.victimId = resultSet.getInt("victim_id")
            fightMove.damage = resultSet.getInt("damage")
            result.add(fightMove)
        }

        return result
    }

}