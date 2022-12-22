package com.vakzu.musicwars.controllers

import com.vakzu.musicwars.dto.LoginDto
import com.vakzu.musicwars.dto.RegisterRequest
import com.vakzu.musicwars.security.MyUserPrincipal
import com.vakzu.musicwars.security.UserService
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RestController
import java.security.Principal

@RestController
class AuthController(val userService: UserService) {

    @PostMapping("/register")
    fun registerUser(form: RegisterRequest): LoginDto {
        val userId = userService.registerUser(form.username, form.password)
        return LoginDto(form.username, userId)
    }

    @GetMapping("/user/balance")
    fun getUserBalance(principal: Principal): Int {
        val user = ((principal as UsernamePasswordAuthenticationToken).principal as MyUserPrincipal).user
        return user.balance
    }

}