export interface MeetingTranscriptionResult{transcript:string;summary:string;actionItems:string[];audioDeleted:boolean}
export interface MeetingTranscriptionProvider{transcribe(audio:Uint8Array,language:'id'|'ms'|'en'):Promise<Omit<MeetingTranscriptionResult,'audioDeleted'>>}
export function getMeetingTranscriptionProvider():MeetingTranscriptionProvider|null{return null}
export async function transcribeMeetingEphemeral(audio:Uint8Array,language:'id'|'ms'|'en'):Promise<MeetingTranscriptionResult>{try{const provider=getMeetingTranscriptionProvider();if(!provider)throw new Error('TRANSCRIPTION_PROVIDER_NOT_CONFIGURED');const result=await provider.transcribe(audio,language);return {...result,audioDeleted:true}}finally{audio.fill(0)}}
