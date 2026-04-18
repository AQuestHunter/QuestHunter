import { existsSync, readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const envPath = join(root, '.env')

function parseEnv(contents) {
  /** @type {Record<string, string>} */
  const out = {}
  for (const line of contents.split(/\r?\n/)) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const eq = trimmed.indexOf('=')
    if (eq === -1) continue
    const key = trimmed.slice(0, eq).trim()
    let val = trimmed.slice(eq + 1).trim()
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1)
    }
    out[key] = val
  }
  return out
}

const fileEnv = existsSync(envPath) ? parseEnv(readFileSync(envPath, 'utf8')) : {}

const url = process.env.VITE_SUPABASE_URL || fileEnv.VITE_SUPABASE_URL
const key = process.env.VITE_SUPABASE_ANON_KEY || fileEnv.VITE_SUPABASE_ANON_KEY

let ok = true
if (!url || url.includes('YOUR_PROJECT')) {
  console.error('Set VITE_SUPABASE_URL (env or .env) to your Supabase project URL.')
  ok = false
}
if (!key || key.includes('YOUR_ANON')) {
  console.error('Set VITE_SUPABASE_ANON_KEY (env or .env) to your Supabase anon key.')
  ok = false
}

if (!ok) process.exit(1)
console.log('Environment OK (Supabase URL + anon key present).')
