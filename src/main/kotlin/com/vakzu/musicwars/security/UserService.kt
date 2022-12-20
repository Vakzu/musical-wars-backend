package com.vakzu.musicwars.security

import com.vakzu.musicwars.entities.User
import com.vakzu.musicwars.exceptions.NotEnoughMoneyException
import com.vakzu.musicwars.exceptions.UserAlreadyExistsException
import com.vakzu.musicwars.repos.UserRepository
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Service

@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: BCryptPasswordEncoder
): UserDetailsService {

    fun registerUser(username: String, password: String) {
        val existing = userRepository.findByName(username)
        if (existing != null) {
            throw UserAlreadyExistsException(existing.name)
        }

        val user = User()
        user.name = username
        user.password = passwordEncoder.encode(password)
        user.isOnline = true

        userRepository.save(user)
    }

    fun getOnlineUsers(): List<User> {
        return userRepository.getOnlineUsers()
    }

    override fun loadUserByUsername(username: String): UserDetails {
        val existing = userRepository.findByName(username) ?: throw UsernameNotFoundException(username)

        return MyUserPrincipal(existing)
    }

    fun getShopUserInfo(id: Int) = userRepository.getUserShopInfo(id)

    fun buyHero(userId: Int, heroId: Int): Boolean {
        return userRepository.buyHero(userId, heroId)
    }

    fun findByName(username: String): User? = userRepository.findByName(username)

    fun getUserStatistics(userId: Int) = userRepository.getUserStatistics(userId)
}