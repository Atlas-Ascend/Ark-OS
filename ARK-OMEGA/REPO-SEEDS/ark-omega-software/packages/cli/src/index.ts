#!/usr/bin/env node
const allowed=new Set(['status','peer','nodes','resources','capabilities','send','fetch','sync','packet','dispatch','workforce','mission','proof','replay','doctor']);
const cmd=process.argv[2]??'status';
if(!allowed.has(cmd)){console.error(`ARK_COMMAND_DENIED unknown_command=${cmd}`);process.exit(64);}
if(['send','sync','dispatch'].includes(cmd)){console.error(`ARK_MUTATION_BLOCKED command=${cmd} reason=authenticated_adapter_not_configured`);process.exit(77);}
console.log(JSON.stringify({surface:'ARK_OMEGA',command:cmd,state:'SCAFFOLD',mutations:false}));
