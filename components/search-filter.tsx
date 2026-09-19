import { Search } from 'lucide-react';

export function SearchFilter({ placeholder: _placeholder = 'Cari…' }: { placeholder?: string }) {
  return <div className="notice" role="status"><Search /><div><b>Pencarian belum tersedia.</b><p>Hasil hanya akan dapat dicari setelah data dan filter yang ditampilkan benar-benar terhubung. Jelajahi daftar atau sumber yang tersedia.</p></div></div>;
}

