// Friendly server name mappings
export const SERVER_NAMES: Record<string, string> = {
  'hd-1': 'Ultra HD',
  'hd-2': 'HD Pro',
  'megacloud': 'MegaCloud',
  'multicloud': 'MultiCloud',
  'vidstreaming': 'VidStream',
  'streamsb': 'StreamSB',
  'streamtape': 'StreamTape',
  'vidcloud': 'VidCloud',
  'doodstream': 'DoodStream',
  'mixdrop': 'MixDrop',
  'upstream': 'UpStream',
  'mp4upload': 'MP4Upload',
  'filemoon': 'FileMoon',
  'watchaw': 'WatchAW',
  'watchanimeworld': 'WatchAnimeWorld',
};

export function getFriendlyServerName(serverName: string): string {
  return SERVER_NAMES[serverName.toLowerCase()] || serverName.charAt(0).toUpperCase() + serverName.slice(1);
}
