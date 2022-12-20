<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Main</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css"
          integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@stomp/stompjs@5.0.0/bundles/stomp.umd.js"></script>
    <script>
        window.onunload = disconnect

        let stompClient = null

        function connect() {
            stompClient = new StompJs.Client({
                brokerURL: 'ws://localhost:8080/game',
                debug: function (str) {
                    console.log(str);
                }
            });

            stompClient.onConnect = function (frame) {
                // setConnected(true);
                console.log('Connected: ' + frame);
                stompClient.subscribe('/user/' + ${user.id} + '/queue/invites', function (messageOutput) {
                    let msg = JSON.parse(messageOutput.body)
                    let result = confirm(msg.senderName + " invites you to join their lobby")
                    if (result) {
                        fetch("/lobby/join?lobbyId=" + msg.lobbyId, {
                            method: "POST"
                        }).then(res => {
                            if (res.redirected) {
                                window.location = res.url
                            }
                        })
                    }
                });
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
                    body: JSON.stringify({type: "JOIN", userId: "${user.id}", username: "${user.name}"})
                })
            }
            stompClient.activate();
        }

        function disconnect() {
            if (stompClient != null) {
                stompClient.publish({
                    destination: "/ws/online",
                    body: JSON.stringify({type: "LEAVE", userId: "${user.id}", username: "${user.name}"})
                })
                stompClient.deactivate();
            }
            console.log("Disconnected");
        }

        function buyHero(heroId) {
            fetch("/buy/hero?hero_id=" + heroId, {
                method: "POST"
            }).then(res => {
                if (res.status !== 200) {
                    alert(res.body)
                } else {
                    res.text().then(text => {
                            console.log(text)
                            let btn = document.querySelector("#hero-" + heroId + " button")
                            btn.disabled = true
                            let balance = document.querySelector("#balance")
                            balance.innerHTML = "" + (Number(balance.innerHTML.replaceAll(",", "")) - Number(btn.innerHTML.replace("$", "")))
                        }
                    )
                }
            })
        }

        function buy_effect(effectId) {
            fetch("/buy/effect?effect_id=" + effectId, {
                method: "POST"
            }).then(res => {
                if (res.status !== 200) {
                    alert(res.body)
                } else {
                    res.text().then(text => {
                            console.log(text)
                            let span = document.querySelector("#effect-" + effectId + " .inventory")
                            let price = document.querySelector("#effect-" + effectId + " button").innerHTML
                            span.innerHTML = "" + (Number(span.innerHTML) + 1)
                            let balance = document.querySelector("#balance")
                            balance.innerHTML = "" + (Number(balance.innerHTML.replaceAll(",", "")) - Number(price))
                        }
                    )
                }
            })
        }
    </script>
</head>
<body onload="connect()">
<div style="position: absolute; right: 12em"></div>
<div>
    <h1>Hello, ${user.name}</h1>
    <h3>Your current balance: <span id="balance">${user.balance?string.computer}</span></h3>
    <form action="/lobby/create" method="POST">
        <button class="btn btn-primary" type="submit">Create lobby</button>
    </form>
</div>

<div style="display: flex; justify-content: center">
    <#list heroes as hero>
        <div id="hero-${hero.hero_id}" class="card" style="width: 18rem;">
            <img class="card-img-top" src="images/${hero.img_path}" alt="Card image cap">
            <div class="card-body">
                <h5 class="card-title">${hero.name}</h5>
                <p class="card-text">Health: ${hero.health}</p>
                <#if hero.user_id??>
                    <button type="button" onclick="buyHero(${hero.hero_id})" class="btn btn-primary" disabled>${hero.price?string.computer}$</button>
                <#else>
                    <button type="button" onclick="buyHero(${hero.hero_id})" class="btn btn-primary">${hero.price?string.computer}$</button>
                </#if>
            </div>
        </div>
    </#list>
</div>
<div style="display: flex; justify-content: center">
    <#list effects as effect>
        <div id="effect-${effect.id}" class="card" style="width: 18rem;" >
            <div class="card-body">
                <h5 class="card-title">${effect.name}</h5>
                <p class="card-text">
                    Stamina: ${effect.stamina}<br>
                    Strength: ${effect.strength}<br>
                    Luck: ${effect.luck}<br>
                    Constitution: ${effect.constitution}<br>
                </p>
                <p>
                    Inventory: <span class="inventory" >${effect.amount}</span>
                </p>
                <button type="button" onclick="buy_effect(${effect.id})" class="btn btn-primary">${effect.price}</button>
            </div>
        </div>
    </#list>
</div>

<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
</body>
</html>