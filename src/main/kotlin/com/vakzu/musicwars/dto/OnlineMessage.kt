package com.vakzu.musicwars.dto

import com.vakzu.musicwars.dto.websocket.CommandType

class OnlineMessage(val type: CommandType, val userId: Int, val username: String)
