from flask import Flask, request, send_file

app = Flask(__name__)


class Ticket:
    def __init__(self, ticket_id, ticket_type, is_valid, is_devaluated):
        self.ticket_id = ticket_id
        self.ticket_type = ticket_type
        self.is_valid = is_valid
        self.is_devaluated = is_devaluated


def toJSON(ticketid, tickettype, isvalid, isdevaluated):
    return "{\"ticketID\": \"" + ticketid + "\",\"ticketType\" : \"" + tickettype + "\",\n\"isValid\" : " + str(isvalid).lower() + ",\n\"isDevaluated\" : " + str(isdevaluated).lower() + "\n}"


d1 = Ticket('1', "regular", True, False)
d2 = Ticket('2', "reduced", True, False)
d3 = Ticket('3', "volunteer", True, False)
d4 = Ticket('4', "regular", True, False)
mylist = [d1, d2, d3, d4]

thisdict = {
  "1": d1,
  "2": d2,
  "3": d3,
  "4": d4
}


@app.route("/")
def index():
    ticket_id_to_validate = request.args.get("d")
    if thisdict.__contains__(ticket_id_to_validate) == False:
        return toJSON(request.args.get("d"), "unknown", False, False)
    if thisdict[ticket_id_to_validate].is_devaluated == False:
        thisdict[ticket_id_to_validate].is_devaluated = True
        return toJSON(thisdict[ticket_id_to_validate].ticket_id, thisdict[ticket_id_to_validate].ticket_type, thisdict[ticket_id_to_validate].is_valid, False)
    return toJSON(thisdict[ticket_id_to_validate].ticket_id, thisdict[ticket_id_to_validate].ticket_type, thisdict[ticket_id_to_validate].is_valid, thisdict[ticket_id_to_validate].is_devaluated)


@app.route("/app")
def a():
    return send_file("C:/Flutter/Projects/ticket_scanner/build/app/outputs/flutter-apk/app-release.apk")


if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0")
