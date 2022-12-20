package com.vakzu.musicwars.dto

interface StatisticsDTO {
    fun getGamesCount(): Int
    fun getWinsCount(): Int
    fun getAveragePlace(): Double
    fun getLastGameDate(): String
}