package com.flipkart.solr.ltr.cache;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import com.codahale.metrics.MetricRegistry;
import org.apache.solr.metrics.MetricsMap;
import org.apache.solr.metrics.SolrMetricManager;
import org.apache.solr.search.CacheRegenerator;
import org.apache.solr.search.SolrCache;
import org.apache.solr.search.SolrCacheBase;
import org.apache.solr.search.SolrIndexSearcher;

public class NoEvictionCache<K,V> extends SolrCacheBase implements SolrCache<K,V> {
  private Map<K,V> map;

  private String description="NoEviction Cache";

  private MetricsMap cacheMap;

  private Set<String> metricNames = ConcurrentHashMap.newKeySet();
  private MetricRegistry registry;

  @Override
  @SuppressWarnings("unchecked")
  public Object init(Map args, Object persistence, CacheRegenerator regenerator) {
    super.init(args, regenerator);
    String str = (String)args.get("initialSize");
    final int initialSize = str==null ? 1024 : Integer.parseInt(str);
    description = generateDescription(initialSize);

    map = new ConcurrentHashMap<>(initialSize);

    return persistence;
  }

  @Override
  public int size() {
    return map.size();
  }

  @Override
  public V put(K key, V value) {
    return map.put(key, value);
  }

  @Override
  public V get(K key) {
    return map.get(key);
  }

  @Override
  public void clear() {
    map.clear();
  }

  @Override
  public void warm(SolrIndexSearcher searcher, SolrCache<K, V> old) {
    // NOTE:fkltr warmup not supported.
  }

  @Override
  public void close() {

  }

  @Override
  public String getName() {
    return NoEvictionCache.class.getName();
  }

  @Override
  public String getDescription() {
    return description;
  }

  @Override
  public Set<String> getMetricNames() {
    return metricNames;
  }

  @Override
  public void initializeMetrics(SolrMetricManager manager, String registryName, String tag, String scope) {
    this.registry = manager.registry(registryName);
    this.cacheMap = new MetricsMap((detailed, res) -> res.put("size", map.size()));
    manager.registerGauge(this, registryName, cacheMap, tag, true, scope, getCategory().toString());
  }

  @Override
  public MetricRegistry getMetricRegistry() {
    return registry;
  }

  @Override
  public String toString() {
    return name() + (cacheMap != null ? cacheMap.getValue().toString() : "");
  }

  private String generateDescription(int initialSize) {
    String description = "NoEviction Cache(initialSize=" + initialSize;
    if (isAutowarmingOn()) {
      description += ", " + getAutowarmDescription();
    }
    description += ')';
    return description;
  }
}
