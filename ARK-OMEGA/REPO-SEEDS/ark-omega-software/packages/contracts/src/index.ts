export type Health='READY'|'DEGRADED'|'DRAINING'|'OFFLINE'|'QUARANTINED';
export type RoutingMode='DIRECT'|'AUTO'|'MESH';
export interface ArkNode {node_id:string;vessel:string;trust_domain:string;transports:string[];capabilities:string[];resources:Record<string,unknown>;health:Health;policy_labels:string[];last_seen:string;protocol_version:string;}
export interface MissionEvent {mission_id:string;event_id:string;sequence:number;timestamp:string;actor?:string;node_id?:string;packet_id?:string;event_type:string;state_from?:string|null;state_to?:string|null;payload_ref?:string|null;payload_hash?:string|null;receipt_ref?:string|null;}
export interface TransferEnvelope {transfer_id:string;mission_id:string;source:string;destination:string;content_type:string;content_hash:string;size:number;created_at:string;ttl_seconds:number;route_policy:RoutingMode;ack_required:boolean;}
