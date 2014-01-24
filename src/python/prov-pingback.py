#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/src/python/prov-pingback.py>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/prizms/wiki/prov-pingback>,
#3>                          <https://github.com/timrdf/prizms/issues/19>;
#3> .
#
# https://github.com/timrdf/csv2rdf4lod-automation/wiki/SDV-organization
#    --cr-conversion-root=/Users/me/projects/twc-ieeevis/data/source
#
#

WHITE_LIST='provenanceweb.org'

from urlparse import urlparse, urlunparse
import re
import uuid
from datetime import datetime
import argparse
import os
import hashlib
import pytz

from flask import Flask
from flask import request
from werkzeug import secure_filename
app = Flask(__name__)

#3> <#getTodayEpochHashName> 
#3>    prov:alternateOf <java:NameFactory.getTodayEpochHashName>,
#3>                     [ dcterms:description "date +%Y%m%d`-`date +%s`-`resource-name.sh | awk '{print substr($0,1,4)}'" ];
#3>    rdfs:seeAlso <https://github.com/tetherless-world/opendap/wiki/Use-case:-mockup-tracer#processing-data-from-opendap-using-http> .
def getTodayEpochHashName(hashLength):
    now = datetime.today()
    return now.strftime('%Y%m%d-%s') + '-' + str(uuid.uuid4())[0:hashLength]

def getLocationHashName(location):
    return hashlib.md5(location).hexdigest()

@app.route("/") 
def hello(): 
    return "Hello World!"

@app.route('/<path:path>', methods=['GET', 'POST'])
def acceptPingback(path):

    steps = path.rsplit('/')

    if len(steps) < 1:
        return 'Resource ID not provided. Please use the pingback URI provided to you in the HTTP Response Header when you requested the original resource.', 406

    resourceID       = steps[0]
    authenticationID = steps[1]

    if request.method == 'POST':

        if len(steps) < 2 or steps[1] != 'mykey':
            return 'Authentication key mismatch; Please use the pingback URI provided to you in the HTTP Response Header when you requested the original resource.', 406

        if len(request.form['provenance']) > 0 and request.form['provenance'].startswith('http'):
            url6 = urlparse(request.form['provenance'])
            urlHash = getLocationHashName(request.form['provenance'])

            sourceID  = re.sub('\.','-',url6.netloc)
            datasetID = 'prov-pingback'
            versionID = resourceID + '-' + urlHash #getTodayEpochHashName(4)

            sourceOrg        = CR_BASE_URI+'''/source/'''+sourceID
            abstractDataset  = CR_BASE_URI+'''/source/'''+sourceID+'''/dataset/'''+datasetID
            versionedDataset = CR_BASE_URI+'''/source/'''+sourceID+'''/dataset/'''+datasetID+'''/version/'''+versionID

            if not os.path.exists(CR_CONVERSION_ROOT + '/' + sourceID + '/' + datasetID + '/version/' + versionID):
                os.makedirs(CR_CONVERSION_ROOT + '/' + sourceID + '/' + datasetID + '/version/' + versionID)
            # Analogous implementation (bash): https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/cr-dcat-retrieval-url.sh
            access = '''#
#3> <> dcterms:modified "'''+datetime.now(pytz.utc).isoformat()+'''"^^xsd:dateTime .
#

@prefix rdfs:       <http://www.w3.org/2000/01/rdf-schema#> .
@prefix conversion: <http://purl.org/twc/vocab/conversion/> .
@prefix dcat:       <http://www.w3.org/ns/dcat#> .
@prefix void:       <http://rdfs.org/ns/void#> .
@prefix nfo:        <http://www.semanticdesktop.org/ontologies/nfo/#> .
@prefix prov:       <http://www.w3.org/ns/prov#> .
@prefix datafaqs:   <http://purl.org/twc/vocab/datafaqs#> .
@prefix :           <'''+CR_BASE_URI+'''/id/> .

<'''+versionedDataset+'''>
   a void:Dataset, dcat:Dataset;
   conversion:source_identifier  "'''+sourceID+'''";
   conversion:dataset_identifier "'''+datasetID+'''";
   prov:wasDerivedFrom :download_'''+urlHash+''';
.

:download_'''+urlHash+'''
   a dcat:Distribution;
   dcat:downloadURL <'''+request.form['provenance']+'''>;
.

#<dataset/755681424697599a2e78460627dbf149>
#   a dcat:Dataset;
#   dcat:distribution :download;
#.
'''
            f = open(CR_CONVERSION_ROOT + '/' + sourceID + '/' + datasetID + '/version/' + versionID + '/access.ttl', 'w')
            f.write(access)
            f.close()
            #if len(url6) > 0 and 
            #f = request.files['the_file']
            #f.save('/home/prizms/prizms/opendap/data/source' + secure_filename(f.filename))
            return '<a href="' + request.form['provenance'] + '">' + request.form['provenance'] + '</a><br/>' \
                   'should contain provenance about derivations of the resource:<br/>'+  \
                    'conversion:version_identifier: ' + steps[0] + '<br/><br/>' + \
                    'Your pingback created <a href="'+versionedDataset+'">a void:Dataset with SDV attributes</a>:<br/><dl>' + \
                    '<dt>source-id:</dt> <dd><a href="' + sourceOrg        + '">' + sourceID + '</a></dd></dt>' + \
                    '<dt>dataset-id:</dt><dd><a href="' + abstractDataset  + '">' + datasetID + '</a></dd></dt>' + \
                    '<dt>version-id:</dt><dd><a href="' + versionedDataset + '">' + versionID + '</a></dd></dt></dl>'
        else:
            return 'The provenance should be provided using the parameter named "provenance", with a URI value. Retry the request with that parameter set.', 400
            
        return 'Input not valid', 400
    else:
        return '''
<html>
    <meta>
       <title>PROV pingback for '''+resourceID+'''</title>
    </meta>
    <body>
    <p>... description of '''+resourceID+''' (from SPARQL) ...</p>
    <form action="/prov-pingback/'''+path+'''" method="post" enctype="multipart/form-data">
        <!--input type="file" name="file"/> <br/-->
        <dl>
        <dt>Report provenance of <a href="'''+resourceID+'''">'''+resourceID+'''</a>'s downstream derivations:</dt><dd><input type="url" name="provenance" size="200" value="http://provenanceweb.org/source/provenanceweb/file/opendap-mockup-tracer/version/2014-Jan-23/source/1-239.nc.prov.ttl"/></dd>
        </dl>
        <input type="submit"/> 
    </form> <br/>
    <p>If you would like to report downstream provenance automatically, you can use curl:</p>
    <code>
        curl --data-urlencode provenance=http://...1-239.nc.prov.ttl http://opendap.tw.rpi.edu/prov-pingback/'''+resourceID+'''/mykey
    </code>
    <body>
</html>
'''

#
# python prov-pingback.py --host 192.168.1.62 --port 9412 --cr-base-uri=http://opendap.tw.rpi.edu --cr-conversion-root=/home/prizms/prizms/opendap/data/source
#
if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='PROV Pingback', epilog="And that's how you'd foo a bar")
    parser.add_argument('--host', nargs='?', help='IP of server')
    parser.add_argument('--port', nargs='?', default=9412, help='Port to listen to', type=int)
    parser.add_argument('--cr-base-uri',        nargs=1, help='Dataspace domain name')
    parser.add_argument('--cr-conversion-root', nargs=1, help='Prizms data root')
    args = parser.parse_args()
   
    CR_BASE_URI        = args.cr_base_uri[0]
    CR_CONVERSION_ROOT = args.cr_conversion_root[0]
 
    app.debug = True
    if 'host' in args:
        app.run(host=args.host, port=args.port)
    else:
        app.run(port=args.port)
