Example:

```json
GET /_search
{
  "query": { 
    "bool": { 
      "must": [
        { "match": { "title":   "Search"        }},
        { "match": { "content": "Elasticsearch" }}
      ],
      "filter": [ 
        { "term":  { "status": "published" }},
        { "range": { "publish_date": { "gte": "2015-01-01" }}}
      ]
    }
  }
}
```

Queries are mostly used for (fuzzy) matching and full text search.
Queries are less performant and often not cached.

Filters are used for exact matching, range, and other filters.
Frequently used filters are cached and reused.

Below query:
```json
{
  "bool" : {
    "must" : [
      {
        "terms" : {
          "category_ids" : [
            "1070"
          ],
          "boost" : 1.0
        }
      },
      {
        "terms" : {
          "visibility" : [
            "2",
            "4"
          ],
          "boost" : 1.0
        }
      },
      {
        "terms" : {
          "toon_in_categorie" : [
            "1"
          ],
          "boost" : 1.0
        }
      }
    ],
    "should" : [
      {
        "terms" : {
          "sku_value" : [
            "XXXX30",
            "XXXX59",
            "XXXX83",
            "XXXX95",
            "XXXXCC",
            "XXXXLA",
            "XXXXSA",
            "XXXXSD",
            "XXXXSX",
            "XXXXTT"]          ],
          "boost" : 1.0
        }
      }
    ],
    "adjust_pure_negative" : true,
    "minimum_should_match" : "1",
    "boost" : 1.0
  }
}
```
Can perform better when optimising with filters.
```json
{
  "bool": {
    "filter": [
      {
        "term": {
          "category_ids": "1070"
        }
      },
      {
        "terms": {
          "visibility": ["2", "4"]
        }
      },
      {
        "term": {
          "toon_in_categorie": "1"
        }
      }
    ],
    "should": [
      {
        "terms": {
          "sku_value": [
            "XXXX30",
            "XXXX59",
            "XXXX83",
            "XXXX95",
            "XXXXCC",
            "XXXXLA",
            "XXXXSA",
            "XXXXSD",
            "XXXXSX",
            "XXXXTT"
          ]
        }
      }
    ],
    "minimum_should_match": "1"
  }
}
```

But what about a query with lots of terms?

Split the terms:

```json
{
  "bool": {
    "filter": [
      {
        "term": {
          "category_ids": "1070"
        }
      },
      {
        "terms": {
          "visibility": ["2", "4"]
        }
      },
      {
        "term": {
          "toon_in_categorie": "1"
        }
      }
    ],
    "should": [
      {
        "terms": {
          "sku_value": [
            "XXXX30",
            "XXXX59",
            "XXXX83"
          ]
        }
      },
      {
        "terms": {
          "sku_value": [
            "XXXX95",
            "XXXXCC",
            "XXXXLA"
          ]
        }
      },
      {
        "terms": {
          "sku_value": [
            "XXXXSA",
            "XXXXSD",
            "XXXXSX",
            "XXXXTT"
          ]
        }
      }
    ],
    "minimum_should_match": "1"
  }
}
```

Caution! Above queries are an example. Results should be checked.
Terms splitting will also have a sweet spot that should be found by measuring query time.
Above query will leverage cache if used often, preventing memory leaks.