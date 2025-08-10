import { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faRightLeft } from "@fortawesome/free-solid-svg-icons";
import { CURRENCIES } from "../currencies";

export default function ConverterForm({ onSubmit, isSubmitting }) {
  const [amount, setAmount] = useState("100");
  const [from, setFrom] = useState("USD");
  const [to, setTo] = useState("EUR");
  const [error, setError] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);

    const amt = Number(amount);
    if (Number.isNaN(amt) || amt <= 0) return setError("Amount must be a positive number.");
    if (from === to) return setError("Source and target currencies must differ.");

    try {
      await onSubmit(amt, from, to);
    } catch (err) {
      setError(err?.message || "Request failed.");
    }
  }

  function swap() {
    setFrom(to);
    setTo(from);
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-white dark:bg-gray-900 rounded-2xl shadow-md p-5 space-y-4 border border-gray-100 dark:border-gray-800"
    >
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <input
          type="number"
          step="0.01"
          min="0"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="Amount"
          aria-label="Amount"
          className="w-full rounded-lg border border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
        <div className="flex gap-2">
          <select
            value={from}
            onChange={(e) => setFrom(e.target.value)}
            aria-label="From currency"
            className="w-full rounded-lg border border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {CURRENCIES.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
          <button
            type="button"
            onClick={swap}
            className="shrink-0 inline-flex items-center justify-center rounded-lg border border-gray-300 dark:border-gray-700 px-3 py-2 hover:bg-gray-50 dark:hover:bg-gray-700"
            title="Swap"
          >
            <FontAwesomeIcon icon={faRightLeft} className="h-4 w-4" aria-hidden="true" />
            <span className="sr-only">Swap</span>
          </button>
        </div>
        <select
          value={to}
          onChange={(e) => setTo(e.target.value)}
          aria-label="To currency"
          className="w-full rounded-lg border border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        >
          {CURRENCIES.map((c) => (
            <option key={c} value={c}>{c}</option>
          ))}
        </select>
      </div>

      {error && <div className="text-red-600 text-sm">{error}</div>}

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full rounded-lg bg-indigo-600 text-white font-medium px-4 py-2 hover:bg-indigo-700 disabled:opacity-50"
      >
        {isSubmitting ? "Converting…" : "Convert"}
      </button>
    </form>
  );
}
