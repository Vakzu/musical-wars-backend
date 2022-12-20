package com.vakzu.musicwars.repos;

import com.vakzu.musicwars.entities.Song
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface SongRepository : JpaRepository<Song, Int> {

    @Query(nativeQuery = true,
        value =  "SELECT * from get_available_songs_for_character(?1)")
    fun getCharacterAvailableSongs(characterId: Int): List<Song>
}