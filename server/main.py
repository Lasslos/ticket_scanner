from flask import Flask, abort, redirect, url_for, render_template, request
import json

app = Flask(__name__)


class Ticket:
    def __init__(self, ticketid, tickettype, isvalid, isdevaluated):
        self.ticketid = ticketid
        self.tickettype = tickettype
        self.isvalid = isvalid
        self.isdevaluated = isdevaluated


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
        if x.ticketid == request.args.get("d"):
            if x.isdevaluated == False:
                x.isdevaluated = True
                return toJSON(x.ticketid, x.tickettype, x.isvalid, False)
            return toJSON(x.ticketid, x.tickettype, x.isvalid, x.isdevaluated)
    return toJSON(request.args.get("d"), "unknown", False, False)

@app.route("/a")
def a():
    return request.args.get("d")


if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0")
