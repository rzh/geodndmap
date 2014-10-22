import json
import pymongo

from bottle import *
from bottle import static_file


MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DB = 'visuals'
MONGO_COLL = 'geo'
app = Bottle()
client = pymongo.MongoClient(MONGO_HOST, MONGO_PORT)
p='''
[{
  "type": "Polygon",
  "coordinates": [
    [
      [
        -80.267831,
        42.050312
      ],
      [
        -80.267831,
        45.003652
      ],
      [
        -73.362579,
        45.003652
      ],
      [
        -73.362579,
        42.050312
      ],
      [
        -80.267831,
        42.050312
      ]
    ]
  ]
},

{
  "type": "Polygon",
  "coordinates": [
    [
      [
        -70.267831,
        42.050312
      ],
      [
        -70.267831,
        45.003652
      ],
      [
        -63.362579,
        45.003652
      ],
      [
        -63.362579,
        42.050312
      ],
      [
        -70.267831,
        42.050312
      ]
    ]
  ]
}
]
'''


def main():
    run(app, host='localhost', port=8080)

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
    # TODO: pass 'explain' to parser
    # return template('<h3>Explain Output for {{query}}'
    #                '</h3><pre>{{explain}}</pre>',
    #                **locals())
    return p

if __name__ == '__main__':
    main()
