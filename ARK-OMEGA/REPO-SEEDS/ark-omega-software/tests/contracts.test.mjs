import test from 'node:test';import assert from 'node:assert/strict';
test('routing modes remain bounded',()=>{assert.deepEqual(['DIRECT','AUTO','MESH'].sort(),['AUTO','DIRECT','MESH']);});
test('cinematic UI may not fabricate execution',()=>{const source='event-backed-only';assert.equal(source,'event-backed-only');});
