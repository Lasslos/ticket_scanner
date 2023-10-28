import json

from flask import Flask, request, send_file

app = Flask(__name__)

class Ticket:
    def __init__(self, ticket_id, ticket_type, is_valid, is_devaluated):
        self.ticket_id = ticket_id
        self.ticket_type = ticket_type
        self.is_valid = is_valid
        self.is_devaluated = is_devaluated


def toJSON(ticketid, tickettype, isvalid, isdevaluated):
    return "{\"ticketID\": \"" + ticketid + "\",\"ticketType\" : \"" + tickettype + "\",\n\"isValid\" : " + str(
        isvalid).lower() + ",\n\"isDevaluated\" : " + str(isdevaluated).lower() + "\n}"


@app.route("/")
def index():
    ticket_id_to_validate = request.args.get("id")
    read_from_json()
    if thisdict.__contains__(ticket_id_to_validate) == False:
        return toJSON(request.args.get("id"), "unknown", False, False)
    if thisdict[ticket_id_to_validate]["is_devaluated"] == False:
        thisdict[ticket_id_to_validate]["is_devaluated"] = True
        write_to_json()
        return toJSON(thisdict[ticket_id_to_validate]["ticket_id"], thisdict[ticket_id_to_validate]["ticket_type"],
                      thisdict[ticket_id_to_validate]["is_valid"], False)
    return toJSON(thisdict[ticket_id_to_validate]["ticket_id"], thisdict[ticket_id_to_validate]["ticket_type"],
                  thisdict[ticket_id_to_validate]["is_valid"], thisdict[ticket_id_to_validate]["is_devaluated"])


@app.route("/app")
def deliver_app():
    return send_file("C:/Flutter/Projects/ticket_scanner/build/app/outputs/flutter-apk/app-release.apk")


def write_to_json():
    with open("Resources/tickets.json", "w") as fo:
        fo.write(json.dumps(thisdict, default=lambda o: o.__dict__, indent=4))


def read_from_json():
    with open('Resources/tickets.json') as json_file:
        global thisdict
        thisdict = json.load(json_file)
    #print(type(thisdict["1"]))


if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0")
