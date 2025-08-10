export default function HistoryList({ items, loading, error }) {
  return (
    <div className="mt-6">
      <h3 className="text-base font-semibold text-gray-800 mb-3">Recent Conversions</h3>

      {loading && <div className="text-gray-600">Loading history…</div>}
      {error && <div className="text-red-600">{error}</div>}

      {!loading && !error && (
        <ul className="space-y-2">
          {items.map((c) => (
            <li key={c.id} className="bg-white rounded-xl border border-gray-100 shadow-sm p-4">
              <div className="flex items-center justify-between">
                <div className="font-medium">
                  {c.amount} {c.base_currency}
                  <span className="mx-2 text-gray-400">→</span>
                  {c.converted_amount} {c.target_currency}
                </div>
                <div className="text-xs text-gray-500">
                  {new Date(c.created_at).toLocaleString()}
                </div>
              </div>
              <div className="mt-1 text-xs text-gray-600">
                Rate: <span className="font-mono">{c.rate_used}</span>{" "}
                • {new Date(c.rate_timestamp).toLocaleString()}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
