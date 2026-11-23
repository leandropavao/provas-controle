"""Delete the encrypted files of every exam whose download window has closed.
exams.json entries keep their metadata, so the page shows them as closed."""
import json
from datetime import datetime, timezone
from pathlib import Path

now = datetime.now(timezone.utc)
for e in json.loads(Path("exams.json").read_text(encoding="utf-8")):
    until = e.get("open_until")
    if until and datetime.fromisoformat(until) <= now:
        files = sorted(Path(e["id"]).glob("*.bin"))
        for f in files:
            f.unlink()
        print(f"{e['id']}: encerrado em {until}; {len(files)} arquivo(s) removido(s)")
    else:
        print(f"{e['id']}: aberto (fecha em {until or 'sem prazo'})")
