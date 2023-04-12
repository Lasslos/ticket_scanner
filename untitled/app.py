from flask import Flask, abort, request

app = Flask(__name__)


class Ticket:
    def __init__(self, ticket_id, ticket_type, is_valid, is_devaluated):
        self.ticket_id = ticket_id
        self.ticket_type = ticket_type
        self.is_valid = is_valid
        self.is_devaluated = is_devaluated


def toJSON(ticketid, tickettype, isvalid, isdevaluated):
    return "{\n\"TicketID\": \"" + ticketid + "\",\n\"TicketType\" : \"" + tickettype + "\",\n\"IsValid\" : " + str(
        isvalid).lower() + ",\n\"IsDevaluated\" : " + str(isdevaluated).lower() + "\n}"


d1 = Ticket('1', "regular", True, False)
d2 = Ticket('2', "reduced", True, False)
mylist = [d1, d2]


@app.route("/")
def index():
    if request.args.get("auth") != "authkey":
        return abort(401)
    for x in mylist:
        if x.ticket_id == request.args.get("d"):
            if x.is_devaluated == False:
                x.is_devaluated = True
                return toJSON(x.ticket_id, x.ticket_type, x.is_valid, False)
            return toJSON(x.ticket_id, x.ticket_type, x.is_valid, x.is_devaluated)
    return toJSON(request.args.get("d"), "unknown", False, False)

@app.route("/a")
def a():
    return request.args.get("d")


if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0")
