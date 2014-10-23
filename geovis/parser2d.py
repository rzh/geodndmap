import re


SCALING_FACTOR = 2 ** 32 / 360.0

## Initialized hashedToNormal array
hashedToNormal = [0] * 256
for i in range(16):
    fixed = 0
    for j in range(4):
        if (i & (i << j)) > 0:
            fixed |= 1 << (j * 2)
    hashedToNormal[fixed] = i


def getHashes(s):
    hashes = []
    for match in re.finditer('BinData\(128, ([0-9A-F]+)\)', s):
        m = match.group(1)
        n = int(m, 16)
        hashes.append(n)
    return hashes


# returns { x: Number, y: Number }
def unhash_fast(_hash):
    x = 0
    y = 0
    for i in range(8):
        c = _hash % 256
        _hash /= 256
        t = c & 0x55
        y |= hashedToNormal[t] << (4 * i)
        t = (c >> 1) & 0x55
        x |= hashedToNormal[t] << (4 * i)
    # scaling code
    x /= SCALING_FACTOR
    x -= 180
    y /= SCALING_FACTOR
    y -= 180
    return [x, y]


def to_geojson(list_of_points):
    # Partition list of points into polygons
    polygons = []
    for i in range(0, len(list_of_points), 4):
        polygon_coords = [list_of_points[j + i] for j in range(4)]
        polygon_coords.append(polygon_coords[0])
        polygons.append({'type': 'Polygon',
                         'coordinates': [polygon_coords]})
    return polygons
