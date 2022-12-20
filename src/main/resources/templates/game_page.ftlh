<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@stomp/stompjs@5.0.0/bundles/stomp.umd.js"></script>
    <style>
        .user-block {
            width: 100%; height: 2em; background: red; display: flex
        }
        .tick {
            width: 20%; height: 100%; background: blue; cursor: pointer;
        }
        .user_data {
            width: 80%; background: white; line-height: 2em; padding: 0 4px
        }
    </style>
    <script type="text/javascript">
        window.onunload = disconnect

        let stompClient = null;

        function setConnected(connected) {
            document.getElementById('connect').disabled = connected;
            document.getElementById('disconnect').disabled = !connected;
            document.getElementById('conversationDiv').style.visibility
                = connected ? 'visible' : 'hidden';
            document.getElementById('response').innerHTML = '';
        }

        function connect() {
            stompClient = new StompJs.Client({
                brokerURL: 'ws://localhost:8080/game',
                debug: function (str) {
                    console.log(str);
                }
            });

            stompClient.onConnect = function(frame) {
                // setConnected(true);
                console.log('Connected: ' + frame);
                stompClient.subscribe('/topic/online', function(messageOutput) {
                    resolveOnlineUserMessage(JSON.parse(messageOutput.body));
                });
                stompClient.subscribe('/topic/lobby/${lobbyId}', function(message) {
                    resolveLobbyUserMessage(JSON.parse(message.body))
                })
                stompClient.onStompError = function (frame) {
                    // Will be invoked in case of error encountered at Broker
                    // Bad login/passcode typically will cause an error
                    // Complaint brokers will set `message` header with a brief message. Body may contain details.
                    // Compliant brokers will terminate the connection after any error
                    console.log('Broker reported error: ' + frame.headers['message']);
                    console.log('Additional details: ' + frame.body);
                };
                stompClient.publish({
                    destination: "/ws/online",
                    body: JSON.stringify({ type: "JOIN", userId: "${user.id}", username: "${user.name}" })
                })
            }
            stompClient.activate();
        }

        function disconnect() {
            if(stompClient != null) {
                stompClient.publish({
                    destination: "/ws/online",
                    body: JSON.stringify({ type: "LEAVE", userId: "${user.id}", username: "${user.name}" })
                })
                stompClient.publish({
                    destination: "/topic/lobby/${lobbyId}",
                    body: JSON.stringify({ type: "LEAVE", userId: "${user.id}", username: "${user.name}" })
                })
                stompClient.deactivate();
            }
            console.log("Disconnected");
        }

        function sendInvite(recepientId) {
            if (stompClient != null) {
                stompClient.publish({
                    destination: "/ws/invite",
                    body: JSON.stringify({ senderName: "${user.name}", recepientId: recepientId, lobbyId: "${lobbyId}"})
                })
            }
        }

        function resolveOnlineUserMessage(messageOutput) {
            switch (messageOutput.type) {
                case "JOIN": addUserOnline(messageOutput); break;
                case "LEAVE": removeUserOnline(messageOutput); break;
            }
        }

        function resolveLobbyUserMessage(messageOutput) {
            switch (messageOutput.type) {
                case "JOIN": addUserToLobby(messageOutput); break;
                case "LEAVE": removeLobbyUser(messageOutput); break;
                case "SET_READY": updateReadyUI(messageOutput.userId, "green"); break;
                case "CANCEL_READY": updateReadyUI(messageOutput.userId, "red"); break;
                default: drawBattleMovement(messageOutput); break;
            }
        }

        function clearEverything() {
            let list = document.querySelector("#online-users")
            for (let el of list) {
                el.remove()
            }
        }

        function addUserToLobby(userData) {
            let list = document.querySelector("#lobby-panel")
            if (!isUserAlreadyInList(userData, list.children, 'lobby-user-')) {
                let block = createLobbyUserBlock(userData)
                list.append(block)
            }
        }

        function addUserOnline(userData) {
            let list = document.querySelector("#online-users")
            if (!isUserAlreadyInList(userData, list.children, 'user-')) {
                let block = createBlock(userData)
                list.append(block)
            }
        }

        function isUserAlreadyInList(userData, list, prefix) {
            for (let element of list) {
                if (element.id === prefix + userData.userId) {
                    return true
                }
            }
            return false
        }

        function removeUserOnline(userData) {
            let block = document.querySelector("#user-" + userData.userId)
            block.remove()
        }

        function removeLobbyUser(userData) {
            let block = document.querySelector("#lobby-user-" + userData.userId)
            block.remove()
        }

        function leaveLobby(lobbyId) {
            if (stompClient != null) {
                fetch("/lobby/leave?lobbyId=" + lobbyId, {
                    method: "POST",
                    redirect: "follow"
                }).then(res => {
                    if (res.redirected) {
                        window.location = res.url
                    }
                })
            }
        }

        function createBlock(userData) {
            let outer = document.createElement("div")
            outer.id = "user-" + userData.userId
            outer.classList.add("user-block")
            let tick = document.createElement("div")
            tick.classList.add("tick")
            tick.onclick = () => sendInvite(userData.userId)
            let inner = document.createElement("div")
            inner.classList.add("user_data")
            inner.innerHTML = userData.username

            outer.append(tick)
            outer.append(inner)

            return outer
        }

        function createLobbyUserBlock(userData) {
            let outer = document.createElement("div")
            outer.id = "lobby-user-" + userData.userId
            outer.classList.add("user-block")
            let name = document.createElement("div")
            name.style.background = "white"
            name.style.lineHeight = "2em"
            name.style.padding = "0 4 px"
            name.style.flexGrow = "7"
            name.innerHTML = userData.username

            let status = document.createElement("div")
            status.style.background = "red"
            status.style.flexGrow = "1"
            status.classList.add("ready-status")

            outer.append(name)
            outer.append(status)

            return outer
        }

        let effects = [
            {
                id: 0,
                name: "None",
                stamina: 0,
                strength: 0,
                constitution: 0,
                luck: 0,
            },
            <#list effects as effect>
            {
                id: ${effect.id},
                name: "${effect.name}",
                stamina: ${effect.stamina},
                strength: ${effect.strength},
                constitution: ${effect.constitution},
                luck: ${effect.luck},
            },
            </#list>
        ]

        let heroList = [
            <#list heroes as hero>
            {
                id: ${hero.id},
                name: "${hero.heroName}",
                health: ${hero.heroHealth}
            },
            </#list>
        ]

        function update_effect_stats() {
            let effectId = Number(document.querySelector("#effect-select").value)
            let effect = effects.find(e => e.id === effectId)
            document.querySelector("#stamina").innerHTML = effect.stamina
            document.querySelector("#strength").innerHTML = effect.strength
            document.querySelector("#constitution").innerHTML = effect.constitution
            document.querySelector("#luck").innerHTML = effect.luck
        }

        function update_hero_stats() {
            let heroId = Number(document.querySelector("#hero-select").value)
            update_songs(heroId)
            let hero = heroList.find(h => h.id === heroId)
            document.querySelector("#health").innerHTML = hero.health
        }

        let songs = []

        function update_songs(heroId) {
            let songSelector = document.querySelector("#song-select")

            fetch("/characters/" + heroId + "/songs", {
                method: "GET"
            }).then(body => body.json()).then(data => {
                for (let song of data) {
                    songs = []
                    songs.push({ id: song.id, name: song.name, damage: song.damage})
                }
                let newChildren = []
                for (let song of songs) {
                    let option = document.createElement("option")
                    option.value = song.id
                    option.innerHTML = song.name
                    newChildren.push(option)
                }
                songSelector.replaceChildren(...newChildren)
                update_song_damage()
            })
        }

        function update_song_damage() {
            let songId = Number(document.querySelector("#song-select").value)
            let song = songs.find(s => s.id === songId)
            document.querySelector("#song-damage").innerHTML = song.damage
        }

        function setReadyState() {
            let characterId = Number(document.querySelector("#hero-select").value)
            let songId = Number(document.querySelector("#song-select").value)
            let effectId = Number(document.querySelector("#effect-select").value)
            let request = { "commandType": "SET_READY", "characterId": characterId, "songId": songId, "effectId": effectId }

            fetch("/war/${lobbyId}/ready/set", {
                method: "POST",
                body: JSON.stringify(request),
                headers: {
                    "Content-Type": "application/json"
                }
            })
        }

        function cancelReadyState() {
            let request = { commandType: "CANCEL_READY" }

            fetch("/war/${lobbyId}/ready/cancel", {
                method: "POST",
                body: JSON.stringify(request),
            })
        }

        let isReady = false
        function resolveReadyState(source) {
            if (isReady) {
                cancelReadyState()
                source.innerHTML = "Ready"
                isReady = false
            } else {
                setReadyState()
                source.innerHTML = "Cancel"
                isReady = true
            }
        }

        function updateReadyUI(uid, color) {
            let block = document.querySelector("#lobby-user-" + uid + " .ready-status")
            block.style.background = color
        }

        function beginFight() {
            let locationId = 1
            fetch("/war/${lobbyId}/start?locationId=" + locationId, {
                method: "POST"
            }).then(res => {
                if (res.status === 400) {
                    alert("Not all players are ready")
                }
                console.log("Battle conducted")
            })
        }

        function drawBattleMovement(moves) {
            console.log(moves)
        }

    </script>
</head>
<body onload="connect()">
    <div style="display: flex; justify-content: center">
        <div style="padding: 0.5em">
            <div id="online-users" style="background: grey; width: 10em; height: 20em; padding: 4px">
                <#list onlineUsers as ou>
                    <div id="user-${ou.id}" class="user-block">
                        <div class="tick" onclick="sendInvite(${ou.id})"></div>
                        <div class="user_data">
                            ${ou.name}
                        </div>
                    </div>
                </#list>
            </div>
        </div>

        <div style="padding: 0.5em; width: 45em">
            <div id="lobby-panel" style="background: grey; width: 100%; height: 20em; padding: 4px;">
                <#list lobbyUsers as lobbyUs>
                    <div id="lobby-user-${lobbyUs.userId}" class="user-block" >
                        <div style="background: white; line-height: 2em; padding: 0 4px; flex-grow: 7">
                            ${lobbyUs.username}
                        </div>
                        <div class="ready-status" style="background: ${lobbyUs.ready?then('green', 'red')}; flex-grow: 1"></div>
                    </div>
                </#list>
            </div>
        </div>
    </div>

    <div style="display: flex; justify-content: center">
        <div style="padding: 0.5em">
            <div id="chat" style="background: grey; width: 35em; height: 20em; padding: 4px">

            </div>
        </div>

        <div style="padding: 0.5em; width: 20em">
            <div id="config-panel" style="background: grey; width: 100%; height: 20em; padding: 4px">
                <div class="user-block" style="background: white; height: fit-content">
                    <div>
                        <label for="hero-select">Select hero:</label>
                        <select name="" id="hero-select" onchange="update_hero_stats()">
                            <#list heroes as hero>
                                <option value="${hero.id}">${hero.heroName}</option>
                            </#list>
                        </select>
                        <#if heroes?size gt 0>
                            <div>Health: <span id="health">${heroes[0].heroHealth}</span></div>
                        </#if>
                    </div>
                </div>

                <div id="effects-block" class="user-block" style="background: white; height: fit-content">
                    <div>
                        <label for="effect-select">Select effect:</label>
                        <select id="effect-select" onchange="update_effect_stats()">
                            <option value="0">None</option>
                            <#list effects as effect>
                                <option value="${effect.id}">${effect.name}</option>
                            </#list>
                        </select>
                        <div>
                            <div>Stamina: <span id="stamina">0</span></div>
                            <div>Constitution: <span id="constitution">0</span></div>
                            <div>Luck: <span id="luck">0</span></div>
                            <div>Strength: <span id="strength">0</span></div>
                        </div>
                        <div>
                        </div>
                    </div>
                </div>

                <div class="user-block" style="background: white">
                    <div>
                        <label for="song-select">Select song:</label>
                        <select name="song-select" id="song-select" onchange="update_song_damage()">
                            <#list songs as song>
                                <option value="${song.id}">${song.name}</option>
                            </#list>
                        </select>
                        <#if songs?size gt 0>
                            <div>Damage: <span id="song-damage">${songs[0].damage}</span></div>
                        </#if>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div style="display: flex; justify-content: center">
        <button type="button" onclick="resolveReadyState(this)" >Ready</button>
        <button type="button" onclick="leaveLobby('${lobbyId}')" >Leave</button>
        <#if isHost>
            <button onclick="beginFight()">Begin fight</button>
        </#if>
    </div>
</body>
</html>
