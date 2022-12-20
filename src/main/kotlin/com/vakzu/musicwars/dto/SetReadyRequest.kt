package com.vakzu.musicwars.dto

import com.vakzu.musicwars.dto.websocket.CommandType

class SetReadyRequest(val commandType: CommandType, val characterId: Int, val songId: Int, val effectId: Int)