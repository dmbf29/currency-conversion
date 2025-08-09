const API_BASE =
  import.meta.env.VITE_API_BASE || "http://localhost:3000/api/v1";

async function asJson(res) {
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(text || `HTTP ${res.status}`);
  }
  return res.json();
}

export async function postConvert(amount, from, to) {
  const res = await fetch(`${API_BASE}/convert`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ amount, from, to }),
  });
  return asJson(res);
}

export async function fetchConversions() {
  const res = await fetch(`${API_BASE}/conversions`);
  return asJson(res);
}
