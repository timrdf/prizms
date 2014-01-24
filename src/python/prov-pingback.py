#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/src/python/prov-pingback.py>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/prizms/wiki/prov-pingback>,
#3>                          <https://github.com/timrdf/prizms/issues/19>,
#3>                          <https://github.com/tetherless-world/opendap/issues/24>,
#3>                          <https://github.com/tetherless-world/opendap/wiki/PROV-Access-and-Query>;
#3> .
#

# example request: http://opendap.tw.rpi.edu/prov-pingback/20140121-1390404237-df2b/$p3c1a7-S@uc3
# see https://github.com/tetherless-world/opendap/wiki/OPeNDAP-Provenance#provenance-of-an-opendap-request-handling

from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run(port=9412)
