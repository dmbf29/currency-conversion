export default function HistoryList({ items, loading, error }) {
  return (
    <div className="mt-6">
      <h3 className="text-base font-semibold text-gray-800 dark:text-gray-100 mb-3">Last 10 Conversions</h3>

      {loading && <div className="text-gray-600 dark:text-gray-300">Loading history…</div>}
      {error && <div className="text-red-600">{error}</div>}

      {!loading && !error && (
        <ul className="space-y-2">
          {items.map((c) => (
            <li key={c.id} className="bg-white dark:bg-gray-900 rounded-xl border border-gray-100 dark:border-gray-800 shadow-sm p-4">
              <div className="flex items-center justify-between">
                <div className="font-medium">
                  {c.amount} {c.base_currency}
                  <span className="mx-2 text-gray-400">→</span>
                  {c.converted_amount} {c.target_currency}
                </div>
                <div className="text-xs text-gray-500 dark:text-gray-400">
                {new Date(c.created_at).toLocaleString(undefined, {
                  month: 'short',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit'
                })}
                </div>
              </div>
              <div className="mt-1 text-xs text-gray-600 dark:text-gray-300">
                Rate: <span className="font-mono">{c.rate_used}</span>{" "}
                • {new Date(c.rate_timestamp).toLocaleDateString()}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
