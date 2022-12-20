package com.vakzu.musicwars.controllers

import com.vakzu.musicwars.dto.OnlineMessage
import com.vakzu.musicwars.config.WebSocketConfig
import com.vakzu.musicwars.dto.websocket.CommandType
import com.vakzu.musicwars.dto.websocket.InviteMessage
import com.vakzu.musicwars.repos.UserRepository
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.messaging.handler.annotation.MessageMapping
import org.springframework.messaging.handler.annotation.SendTo
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.stereotype.Controller
import org.springframework.transaction.annotation.Transactional
import java.security.Principal
import java.util.*

@Controller
class WebSocketController(val messagingTemplate: SimpMessagingTemplate, val userRepository: UserRepository) {

    val log: Logger = LoggerFactory.getLogger(WebSocketConfig::class.java)

    @MessageMapping("/online")
    @SendTo("/topic/online")
    @Transactional
    fun joinOrExit(message: OnlineMessage, userPrincipal: Principal): OnlineMessage {
        log.info("User ${userPrincipal.name} sent message ${message.type}")
        if (message.type == CommandType.JOIN) {
            userRepository.setUserOnline(userPrincipal.name)
        } else {
            userRepository.setUserOffline(userPrincipal.name)
        }
        return message
    }

    @MessageMapping("/invite")
    fun sendInvite(inviteMessage: InviteMessage) {
        messagingTemplate.convertAndSendToUser(
            inviteMessage.recepientId.toString(), "/queue/invites", inviteMessage
        )
    }

}