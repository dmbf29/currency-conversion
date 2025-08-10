import { useEffect, useState } from "react";
import { postConvert, fetchConversions } from "./api";
import ConverterForm from "./components/ConverterForm";
import ResultCard from "./components/ResultCard";
import HistoryList from "./components/HistoryList";
import "./index.css";

export default function App() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [result, setResult] = useState(null);
  const [history, setHistory] = useState([]);
  const [histLoading, setHistLoading] = useState(false);
  const [histError, setHistError] = useState(null);

  async function loadHistory() {
    setHistError(null);
    setHistLoading(true);
    try {
      const data = await fetchConversions();
      setHistory(data);
    } catch (e) {
      setHistError(e.message || "Failed to load history.");
    } finally {
      setHistLoading(false);
    }
  }

  useEffect(() => {
    loadHistory();
  }, []);

  async function handleConvert(amount, from, to) {
    setIsSubmitting(true);
    try {
      const data = await postConvert(amount, from, to);
      setResult(data);
      await loadHistory();
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="max-w-3xl mx-auto px-4 py-6">
      <h1 className="text-2xl font-bold mb-4">Currency Converter</h1>
      <ConverterForm onSubmit={handleConvert} isSubmitting={isSubmitting} />
      <div className="mt-4">
        <ResultCard result={result} />
      </div>
      <HistoryList items={history} loading={histLoading} error={histError} />
    </div>
  );
}
