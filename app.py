import json
import pymongo

from bottle import Bottle, request, response, run, static_file, template
from geovis import parser2d


MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DB = 'test'
MONGO_COLL = 'geo'
app = Bottle()
client = pymongo.MongoClient(MONGO_HOST, MONGO_PORT)


def main():
    run(app, debug=True, host='localhost', port=8080)


@app.hook('after_request')
def enable_cors():
        response.headers['Access-Control-Allow-Origin'] = '*'


@app.route('/static/:path#.+#', name='static')
def static(path):
        return static_file(path, root='./static')


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
                        parser2d.unhash_fast(parser2d.getHashes(index_bnds)))
                    input_stage['indexBoundsObj'] = geo_json
            except KeyError as e:
                explain = str(e)
    return explain

if __name__ == '__main__':
    main()
