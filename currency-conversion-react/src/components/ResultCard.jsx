export default function ResultCard({ result }) {
  if (!result) return null;

  const ts = new Date(result.rate_timestamp).toLocaleDateString();

  return (
    <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-md p-5 border border-gray-100 dark:border-gray-800">
      <div className="flex items-center justify-between">
        <div className="text-lg">
          <span className="font-semibold">
            {result.amount} {result.base_currency}
          </span>
          <span className="mx-2 text-gray-400">→</span>
          <span className="font-semibold">
            {result.converted_amount} {result.target_currency}
          </span>
        </div>
      </div>
      <div className="mt-2 text-sm text-gray-600 dark:text-gray-300">
        <div>Rate used: <span className="font-mono">{result.rate_used}</span></div>
        <div>Rate published: {ts}</div>
      </div>
    </div>
  );
}
