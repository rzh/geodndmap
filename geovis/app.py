import json
import os
import pymongo

import bottle

from bottle import Bottle, request, response, run, static_file, template
from geovis import parser2d


# Set template path
HERE = os.path.dirname(__file__)
bottle.TEMPLATE_PATH.append(os.path.join(HERE, 'views'))


MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DB = 'osm'
MONGO_COLL = 'nodes'
app = Bottle()
client = pymongo.MongoClient(MONGO_HOST, MONGO_PORT)


def main():
    run(app, debug=True, host='localhost', port=8080)


@app.hook('after_request')
def enable_cors():
        response.headers['Access-Control-Allow-Origin'] = '*'


@app.route('/static/:path#.+#', name='static')
def static(path):
        return static_file(path, root=os.path.join(HERE, 'static'))


@app.route('/')
def geo_map():
    return template('map', **locals())


@app.route('/geoQuery')
def do_query():
    try:
        query = json.loads(request.GET['query'])
    except ValueError as e:
        query = "Bad JSON!"
        explain = str(e)
    else:
        try:
            explain = client[MONGO_DB][MONGO_COLL].find(query).explain()
        except Exception as e:
            explain = str(e)
        else:
            try:
                execution_stages = explain['executionStats']['executionStages']
                input_stage = execution_stages['inputStage']['inputStage']
                key_patt = input_stage['keyPattern']
                if '2d' in key_patt.values():
                    # We have a 2d query
                    index_bnds = input_stage['indexBounds']


                    # Parse to geoJSON
                    geo_json = parser2d.to_geojson(
                        map(parser2d.unhash_fast, parser2d.getHashes(index_bnds)))
                    input_stage['indexBoundsObj'] = geo_json



            except KeyError:
                pass
    return explain

if __name__ == '__main__':
    main()
