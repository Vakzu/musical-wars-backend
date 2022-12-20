package com.vakzu.musicwars.dto

import com.vakzu.musicwars.dto.websocket.CommandType

class ReadyResponse(val type: CommandType, val userId: Int)