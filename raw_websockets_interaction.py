import base64
import hashlib
import json

# for version websocket 5.0.0; docs https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md
# note https://obsproject.com/forum/threads/python-script-to-connect-to-obs-websocket-server-help.173395/
# logging.basicConfig(level=logging.DEBUG)
import websocket  # https://pypi.org/project/websocket-client/

# LOG = logging.getLogger(__name__)

host = "localhost"
port = 4455
password = "c7CpTD1EqyZBoBDM"  # change password here
ws = websocket.WebSocket()
url = "ws://{}:{}".format(host, port)
ws.connect(url)


def _build_auth_string(salt, challenge):
    secret = base64.b64encode(
        hashlib.sha256((password + salt).encode("utf-8")).digest()
    )
    auth = base64.b64encode(
        hashlib.sha256(secret + challenge.encode("utf-8")).digest()
    ).decode("utf-8")
    return auth


def _auth():
    message = ws.recv()
    result = json.loads(message)
    server_version = result["d"].get("obsWebSocketVersion")
    auth = _build_auth_string(
        result["d"]["authentication"]["salt"],
        result["d"]["authentication"]["challenge"],
    )
    payload = {
        "op": 1,
        "d": {"rpcVersion": 1, "authentication": auth, "eventSubscriptions": 1000},
    }
    ws.send(json.dumps(payload))
    message = ws.recv()
    result = json.loads(message)


_auth()

payload_text_value = """
send_js "document.documentElement.style.filter='grayscale(100%)'"
sleep(1.3)
send_js [[document.documentElement.style.filter='invert(100%)']]
sleep(0.8)
send_js [==[
document.body.innerHTML = `
<style>body{margin:0;padding:0}canvas{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%)}</style>
<canvas id="cvs" width="100" height="100"></canvas> `;
let r = Math.random;
const c = document.getElementById('cvs').getContext('2d');
c.beginPath();c.moveTo(50, 0);c.lineTo(0, 100);c.lineTo(100, 100);
c.fillStyle=`rgb(${r()*256|0},${r()*256|0},${r()*256|0})`;c.fill();
]==]
"""

#payload_text_value = "print(0)mr = math.random; print(mr()) sleep(0.5) print(mr()) sleep(1) print(mr())print(1)"
payload = {  # sending with new code to run
    "op": 6,
    "d": {
        "requestId": "Set_Console_Settings",
        "requestType": "SetSourceFilterSettings",
        "requestData": {
            "sourceName": "Browser",
            "filterName": "Console",
            "filterSettings": {
                "_text": payload_text_value,
                "_external_dispatch": True,
            },
        },
    },
}
ws.send(json.dumps(payload))
message = ws.recv()
print(message)

##### or you can just run existing code
# payload = {
#     "op": 6,
#     "d": {
#         "requestId": "Set_Console_Settings",
#         "requestType": "SetSourceFilterSettings",
#         "requestData": {
#             "sourceName": "Browser",
#             "filterName": "Console",
#             "filterSettings": {
#                 "_external_dispatch": True,
#             },
#         },
#     },
# }
# ws.send(json.dumps(payload))  # sending with new code to run
# message = ws.recv()
# print(message)

ws.close()
