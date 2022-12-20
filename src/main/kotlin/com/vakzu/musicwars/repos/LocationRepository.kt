package com.vakzu.musicwars.repos;

import com.vakzu.musicwars.entities.Location
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LocationRepository : JpaRepository<Location, Int> {
}