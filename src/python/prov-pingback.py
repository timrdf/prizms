#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/src/python/prov-pingback.py>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/prizms/wiki/prov-pingback>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/prizms/issues/19>;
#3> .
#

from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run(port=9412)
