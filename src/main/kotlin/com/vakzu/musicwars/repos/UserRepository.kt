package com.vakzu.musicwars.repos

import com.vakzu.musicwars.dto.StatisticsDTO
import com.vakzu.musicwars.entities.User
import com.vakzu.musicwars.lobby.HeroShopInfo
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface UserRepository: JpaRepository<User, Long>  {
    fun findByName(username: String): User?

    @Query("SELECT u FROM User u WHERE u.isOnline = true")
    fun getOnlineUsers(): List<User>

    @Modifying
    @Query(nativeQuery = true, value = "UPDATE \"user\" SET is_online=false WHERE name = ?1")
    fun setUserOffline(username: String)

    @Modifying
    @Query(nativeQuery = true, value = "UPDATE \"user\" SET is_online=true WHERE name = ?1")
    fun setUserOnline(username: String)

    @Query(nativeQuery = true, value = "SELECT * FROM get_shop_info_for_user(?1)")
    fun getUserShopInfo(userId: Int): List<HeroShopInfo>

    @Query(nativeQuery = true, value = "SELECT * FROM buy_hero(?1, ?2)")
    fun buyHero(userId: Int, heroId: Int): Boolean

    @Query(nativeQuery = true, value = "SELECT * FROM get_statistics(?1)")
    fun getUserStatistics(userId: Int): StatisticsDTO
}