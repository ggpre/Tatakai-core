import { collectPrometheus } from '@/lib/metrics';

export default function handler(req: any, res: any) {
  // Basic auth optional: use env var to protect metrics endpoint in non-dev
  const basicUser = process.env.METRICS_BASIC_USER;
  const basicPass = process.env.METRICS_BASIC_PASS;
  if (basicUser && basicPass) {
    const auth = req.headers.authorization || '';
    const token = auth.replace(/^Basic /i, '');
    const decoded = Buffer.from(token, 'base64').toString('utf8');
    if (decoded !== `${basicUser}:${basicPass}`) {
      res.setHeader('WWW-Authenticate', 'Basic realm="metrics"');
      return res.status(401).end('Unauthorized');
    }
  }

  const body = collectPrometheus();
  res.setHeader('Content-Type', 'text/plain; version=0.0.4');
  return res.status(200).send(body);
}
