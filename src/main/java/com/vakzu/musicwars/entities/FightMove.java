package com.vakzu.musicwars.entities;

import javax.persistence.*;
import java.util.Collection;

public class FightMove {
    private Integer fightId;

    private Integer moveNumber;

    private Integer attackerId;

    private Integer victimId;

    private Integer damage;

    public Integer getFightId() {
        return fightId;
    }

    public void setFightId(Integer fightId) {
        this.fightId = fightId;
    }

    public Integer getMoveNumber() {
        return moveNumber;
    }

    public void setMoveNumber(Integer moveNumber) {
        this.moveNumber = moveNumber;
    }

    public Integer getAttackerId() {
        return attackerId;
    }

    public void setAttackerId(Integer attackerId) {
        this.attackerId = attackerId;
    }

    public Integer getVictimId() {
        return victimId;
    }

    public void setVictimId(Integer victimId) {
        this.victimId = victimId;
    }

    public Integer getDamage() {
        return damage;
    }

    public void setDamage(Integer damage) {
        this.damage = damage;
    }

}