import json
import pymongo

from bottle import Bottle, request, run, template


MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DB = 'visuals'
MONGO_COLL = 'geo'
app = Bottle()
client = pymongo.MongoClient(MONGO_HOST, MONGO_PORT)


def main():
    run(app, host='localhost', port=8080)


@app.route('/')
def geo_map():
    return template('map', **locals())


@app.route('/geoQuery')
def do_query():
    query = json.loads(request.GET['query'])
    try:
        explain = client[MONGO_DB][MONGO_COLL].find(query).explain()
    except Exception as e:
        explain = str(e)
    # TODO: pass 'explain' to parser
    return template('<h3>Explain Output for {{query}}'
                    '</h3><pre>{{explain}}</pre>',
                    **locals())

if __name__ == '__main__':
    main()
