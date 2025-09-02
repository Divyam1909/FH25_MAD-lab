import 'dart:typed_data';
import 'dart:math';
import 'crypto_models.dart';

/// Network protocol types
enum ProtocolType {
  tcp,
  udp,
  icmp,
  http,
  https,
  tls,
  quic,
  ssh,
  dns,
  dhcp,
  custom,
  blockchain,
  iot,
  mesh,
  quantum,
}

/// Network layer model
enum NetworkLayer {
  physical(1),
  dataLink(2),
  network(3),
  transport(4),
  session(5),
  presentation(6),
  application(7);

  const NetworkLayer(this.level);
  final int level;
}

/// Advanced network packet structure
class NetworkPacket {
  final String packetId;
  final ProtocolType protocol;
  final NetworkLayer layer;
  final String sourceAddress;
  final String destinationAddress;
  final int sourcePort;
  final int destinationPort;
  final Uint8List payload;
  final Map<String, dynamic> headers;
  final DateTime timestamp;
  final int sequenceNumber;
  final int acknowledgmentNumber;
  final List<String> flags;
  final int ttl;
  final int size;
  final String? encryptionType;
  final bool isEncrypted;
  final double latency;
  final int hopCount;
  
  NetworkPacket({
    required this.packetId,
    required this.protocol,
    required this.layer,
    required this.sourceAddress,
    required this.destinationAddress,
    required this.sourcePort,
    required this.destinationPort,
    required this.payload,
    required this.headers,
    required this.timestamp,
    this.sequenceNumber = 0,
    this.acknowledgmentNumber = 0,
    this.flags = const [],
    this.ttl = 64,
    required this.size,
    this.encryptionType,
    this.isEncrypted = false,
    this.latency = 0.0,
    this.hopCount = 0,
  });
  
  String get connectionId => 
    '$sourceAddress:$sourcePort-$destinationAddress:$destinationPort';
}

/// Network connection state
enum ConnectionState {
  closed,
  listening,
  synSent,
  synReceived,
  established,
  finWait1,
  finWait2,
  closeWait,
  closing,
  lastAck,
  timeWait,
  suspended,
  error,
}

/// Advanced network connection
class NetworkConnection {
  final String connectionId;
  final ProtocolType protocol;
  final String localAddress;
  final String remoteAddress;
  final int localPort;
  final int remotePort;
  final ConnectionState state;
  final DateTime establishedAt;
  final Duration duration;
  final int bytesReceived;
  final int bytesSent;
  final int packetsReceived;
  final int packetsSent;
  final double bandwidth;
  final double latency;
  final double jitter;
  final double packetLoss;
  final Map<String, dynamic> qosMetrics;
  final List<String> securityFlags;
  final bool isSecure;
  final String? encryptionCipher;
  final SecurityLevel securityLevel;
  
  NetworkConnection({
    required this.connectionId,
    required this.protocol,
    required this.localAddress,
    required this.remoteAddress,
    required this.localPort,
    required this.remotePort,
    required this.state,
    required this.establishedAt,
    required this.duration,
    this.bytesReceived = 0,
    this.bytesSent = 0,
    this.packetsReceived = 0,
    this.packetsSent = 0,
    this.bandwidth = 0.0,
    this.latency = 0.0,
    this.jitter = 0.0,
    this.packetLoss = 0.0,
    this.qosMetrics = const {},
    this.securityFlags = const [],
    this.isSecure = false,
    this.encryptionCipher,
    this.securityLevel = SecurityLevel.level1,
  });
  
  double get throughput => duration.inMilliseconds > 0 
    ? (bytesReceived + bytesSent) / duration.inMilliseconds * 1000 
    : 0.0;
}

/// Network topology node
class NetworkNode {
  final String nodeId;
  final String nodeType; // router, switch, host, firewall, etc.
  final String ipAddress;
  final List<String> connectedNodes;
  final Map<String, dynamic> capabilities;
  final Map<String, dynamic> configuration;
  final bool isCompromised;
  final List<String> runningServices;
  final Map<String, dynamic> securityPolicies;
  final double trustScore;
  final DateTime lastSeen;
  final List<String> vulnerabilities;
  final Map<String, dynamic> performance;
  
  NetworkNode({
    required this.nodeId,
    required this.nodeType,
    required this.ipAddress,
    required this.connectedNodes,
    required this.capabilities,
    required this.configuration,
    this.isCompromised = false,
    this.runningServices = const [],
    this.securityPolicies = const {},
    this.trustScore = 1.0,
    required this.lastSeen,
    this.vulnerabilities = const [],
    this.performance = const {},
  });
}

/// Network topology graph
class NetworkTopology {
  final String topologyId;
  final String topologyType; // star, mesh, tree, hybrid
  final List<NetworkNode> nodes;
  final List<NetworkConnection> connections;
  final Map<String, dynamic> properties;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final Map<String, double> metrics;
  final List<String> securityZones;
  final Map<String, List<String>> routingTables;
  
  NetworkTopology({
    required this.topologyId,
    required this.topologyType,
    required this.nodes,
    required this.connections,
    required this.properties,
    required this.createdAt,
    required this.lastUpdated,
    this.metrics = const {},
    this.securityZones = const [],
    this.routingTables = const {},
  });
  
  NetworkNode? getNodeById(String nodeId) {
    try {
      return nodes.firstWhere((node) => node.nodeId == nodeId);
    } catch (e) {
      return null;
    }
  }
  
  List<NetworkNode> getConnectedNodes(String nodeId) {
    final node = getNodeById(nodeId);
    if (node == null) return [];
    
    return node.connectedNodes
        .map((id) => getNodeById(id))
        .where((n) => n != null)
        .cast<NetworkNode>()
        .toList();
  }
}

/// Protocol implementation details
class ProtocolImplementation {
  final ProtocolType protocol;
  final String version;
  final Map<String, dynamic> parameters;
  final List<String> supportedCiphers;
  final List<String> supportedExtensions;
  final Map<String, dynamic> defaultHeaders;
  final Duration timeout;
  final int maxRetries;
  final bool supportsMultiplexing;
  final bool supportsCompression;
  final SecurityLevel minSecurityLevel;
  
  ProtocolImplementation({
    required this.protocol,
    required this.version,
    required this.parameters,
    this.supportedCiphers = const [],
    this.supportedExtensions = const [],
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.supportsMultiplexing = false,
    this.supportsCompression = false,
    this.minSecurityLevel = SecurityLevel.level1,
  });
}

/// Traffic analysis patterns
class TrafficPattern {
  final String patternId;
  final String patternType; // periodic, burst, baseline, anomaly
  final List<double> volumeProfile;
  final Map<String, double> protocolDistribution;
  final Map<String, double> portDistribution;
  final Duration timeWindow;
  final double confidence;
  final List<String> indicators;
  final bool isAnomaly;
  final Map<String, dynamic> statistics;
  
  TrafficPattern({
    required this.patternId,
    required this.patternType,
    required this.volumeProfile,
    required this.protocolDistribution,
    required this.portDistribution,
    required this.timeWindow,
    required this.confidence,
    this.indicators = const [],
    this.isAnomaly = false,
    this.statistics = const {},
  });
}

/// Network intrusion detection
class IntrusionSignature {
  final String signatureId;
  final String name;
  final String description;
  final String severity; // Critical, High, Medium, Low
  final List<String> patterns;
  final Map<String, dynamic> conditions;
  final List<ProtocolType> targetProtocols;
  final List<int> targetPorts;
  final bool isRegexBased;
  final bool isStateful;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final double falsePositiveRate;
  final double detectionRate;
  
  IntrusionSignature({
    required this.signatureId,
    required this.name,
    required this.description,
    required this.severity,
    required this.patterns,
    required this.conditions,
    this.targetProtocols = const [],
    this.targetPorts = const [],
    this.isRegexBased = false,
    this.isStateful = false,
    required this.createdAt,
    required this.lastUpdated,
    this.falsePositiveRate = 0.0,
    this.detectionRate = 1.0,
  });
}

/// Network security event
class SecurityEvent {
  final String eventId;
  final String eventType;
  final String severity;
  final NetworkPacket? triggerPacket;
  final String sourceNode;
  final String targetNode;
  final List<String> indicators;
  final Map<String, dynamic> evidence;
  final DateTime detectedAt;
  final double confidence;
  final String? signature;
  final bool isConfirmed;
  final List<String> recommendations;
  final Map<String, dynamic> context;
  
  SecurityEvent({
    required this.eventId,
    required this.eventType,
    required this.severity,
    this.triggerPacket,
    required this.sourceNode,
    required this.targetNode,
    required this.indicators,
    required this.evidence,
    required this.detectedAt,
    required this.confidence,
    this.signature,
    this.isConfirmed = false,
    this.recommendations = const [],
    this.context = const {},
  });
}

/// Custom protocol definition
class CustomProtocol {
  final String protocolName;
  final int protocolNumber;
  final NetworkLayer layer;
  final Map<String, dynamic> headerFormat;
  final List<String> messageTypes;
  final Map<String, dynamic> encryptionScheme;
  final Map<String, dynamic> authenticationScheme;
  final bool supportsFragmentation;
  final bool supportsReliability;
  final Duration keepAliveInterval;
  final Map<String, dynamic> errorHandling;
  final List<String> extensions;
  
  CustomProtocol({
    required this.protocolName,
    required this.protocolNumber,
    required this.layer,
    required this.headerFormat,
    required this.messageTypes,
    this.encryptionScheme = const {},
    this.authenticationScheme = const {},
    this.supportsFragmentation = false,
    this.supportsReliability = false,
    this.keepAliveInterval = const Duration(seconds: 60),
    this.errorHandling = const {},
    this.extensions = const [],
  });
}

/// Quality of Service metrics
class QoSMetrics {
  final double bandwidth;
  final double latency;
  final double jitter;
  final double packetLoss;
  final double throughput;
  final double availability;
  final double reliability;
  final Map<String, double> customMetrics;
  final DateTime measuredAt;
  final Duration measurementPeriod;
  
  QoSMetrics({
    required this.bandwidth,
    required this.latency,
    required this.jitter,
    required this.packetLoss,
    required this.throughput,
    required this.availability,
    required this.reliability,
    this.customMetrics = const {},
    required this.measuredAt,
    required this.measurementPeriod,
  });
  
  double get overallScore {
    // Weighted combination of metrics (0-1 scale)
    return (availability * 0.3) + 
           (reliability * 0.25) + 
           ((1 - packetLoss) * 0.2) + 
           (min(throughput / bandwidth, 1.0) * 0.15) + 
           ((1 - min(latency / 1000, 1.0)) * 0.1);
  }
} 