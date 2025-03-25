# Monitor JVM heap usage and GC metrics
# Use when: Memory pressure, slow queries, or frequent GC pauses
# High "heap.percent" or long GC pauses indicate memory pressure
curl -X GET "http://$VHOSTIP:9200/_nodes/stats/jvm?pretty&human"

# Quick health check of all nodes
# Use when: Performance varies between nodes or cluster is unstable
# Watch for:
# - Uneven heap usage between nodes
# - High CPU or load averages
# - RAM usage above 85%
curl -X GET "http://$VHOSTIP:9200/_cat/nodes?v&h=name,heap.current,heap.percent,ram.percent,cpu,load_1m&pretty"

# Check index sizes and document counts
# Use when: Investigating data distribution or growth patterns
# Watch for: Unexpected doc counts or size variations
curl -X GET "http://$VHOSTIP:9200/_cat/indices?v&h=index,docs.count,docs.deleted,store.size,pri.store.size&pretty&human"

# Analyze field usage and types across indices
# Use when: Finding mapping inconsistencies or unused fields
# Shows field names, types, and whether they're searchable/aggregatable
curl -X GET "http://$VHOSTIP:9200/_mapping?pretty" | more

# Get field value statistics (replace {index} and {field})
# Use when: Looking for outliers or data quality issues
# Shows min/max/avg values and other statistics
curl -X GET "http://$VHOSTIP:9200/{index}/_search?pretty" \
-H "Content-Type: application/json" \
-d '{
  "size": 0,
  "aggs": {
    "field_stats": {
      "stats": {
        "field": "{field}"
      }
    }
  }
}'

# Find indices with abnormal shard sizes
# Use when: Investigating uneven data distribution
# Watch for large size differences between shards
curl -X GET "http://$VHOSTIP:9200/_cat/shards?v&h=index,shard,prirep,docs,store&pretty&human"

# Check for empty fields or null values (replace {index} and {field})
# Use when: Data quality analysis needed
curl -X GET "http://$VHOSTIP:9200/{index}/_search?pretty" \
-H "Content-Type: application/json" \
-d '{
  "size": 0,
  "query": {
    "bool": {
      "must_not": {
        "exists": {
          "field": "{field}"
        }
      }
    }
  }
}'

# Enable detailed query logging (STAGING ONLY!)
# Use when:
# - Investigating slow queries
# - Performance tuning
# - Query optimization
# WARNING: This generates massive amounts of logs
curl -X PUT "http://$VHOSTIP:9200/_all/_settings?pretty" \
-H "Content-Type: application/json" \
-d '{
  "index.search.slowlog.threshold.query.warn": "0s",
  "index.search.slowlog.threshold.query.info": "0s",
  "index.search.slowlog.threshold.query.debug": "0s",
  "index.search.slowlog.threshold.query.trace": "0s",
  "index.search.slowlog.threshold.fetch.warn": "0s",
  "index.search.slowlog.threshold.fetch.info": "0s",
  "index.search.slowlog.threshold.fetch.debug": "0s",
  "index.search.slowlog.threshold.fetch.trace": "0s",
  "index.search.slowlog.level": "TRACE",
  "index.indexing.slowlog.threshold.index.warn": "0s",
  "index.indexing.slowlog.threshold.index.info": "0s",
  "index.indexing.slowlog.threshold.index.debug": "0s",
  "index.indexing.slowlog.threshold.index.trace": "0s",
  "index.indexing.slowlog.level": "TRACE"
}'

# Check thread pool health
# Use when: Query queuing or rejection errors occur
# Warning signs:
# - High 'queue' numbers indicate backup
# - Any 'rejected' count > 0 indicates overload
# - High 'active' count might indicate stuck threads
curl -X GET "http://$VHOSTIP:9200/_cat/thread_pool?v&h=name,active,queue,rejected&pretty"

# Analyze segment health
# Use when:
# - Query performance degradation over time
# - High disk usage
# - Many small segments indicate need for force-merge
# - Large segment count impacts query performance
curl -X GET "http://$VHOSTIP:9200/_cat/segments?v&pretty&human"

# Monitor circuit breaker trips
# Use when: Getting circuit_breaking_exception errors
# Watch for:
# - High tripped count
# - Estimated size close to limit
# - Parent breaker approaching limits
curl -X GET "http://$VHOSTIP:9200/_nodes/stats/breaker?pretty&human"

# Track search queue performance
# Use when: Search latency increases
# Critical metrics:
# - Rejected operations
# - Queue size
# - Active search count
curl -X GET "http://$VHOSTIP:9200/_nodes/stats/thread_pool/search?pretty&human"

# Monitor cache efficiency
# Use when:
# - Query performance inconsistent
# - High memory usage
# Watch for:
# - High eviction rates
# - Low hit ratios
# - Memory pressure from large caches
curl -X GET "http://$VHOSTIP:9200/_nodes/stats/indices/query_cache,request_cache?pretty&human"

# Analyze busy threads
# Use when:
# - CPU usage is high
# - Queries are stuck
# - Thread pools show high active counts
# Shows stack traces of busiest threads
curl -X GET "http://$VHOSTIP:9200/_nodes/hot_threads?threads=10&pretty"