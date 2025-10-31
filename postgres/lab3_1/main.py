import csv
import random
import json
from datetime import datetime, timedelta

# OUTPUT_SQL = "data.sql"

PERFORMANCE_SQL = "lab3_1/performance.sql"
PARTICIPANTS_SQL = "lab3_1/participants.sql"
COMPETITIONS_SQL = "lab3_1/competitions.sql"
DATE_SQL = "lab3_1/date.sql"
OUTCOME_SQL = "lab3_1/outcome.sql"

N_DATES = 1096  # 2023–2025
N_PARTICIPANTS = 1_000_000
N_COMPETITIONS = 1_000_000
N_OUTCOMES = 1_000_000
N_PERFORMANCES = 100_000_000

ALL_DATES = [
    int((datetime(2023, 1, 1) + timedelta(days=d)).strftime("%Y%m%d"))
    for d in range(N_DATES)
]

date2series = {date_id: set() for date_id in ALL_DATES}

competition2date = {}


def load_csv(filename):
    with open(filename, "r", encoding="utf-8") as f:
        return [row[0].strip() for row in csv.reader(f) if row]


first_names = load_csv("primitive_data/first_names.csv")
last_names = load_csv("primitive_data/last_names.csv")
countries = load_csv("primitive_data/countries.csv")
sports = load_csv("primitive_data/sports.csv")
series_list = load_csv("primitive_data/series.csv")
events_list = load_csv("primitive_data/events.csv")
venues_list = load_csv("primitive_data/venues.csv")
disq_codes = ["DQ-01", "DQ-02", "DQ-03", "DQ-04", "DQ-05"]


def escape_copy(s):
    if s is None:
        return r"\N"
    return (
        str(s)
        .replace("\\", "\\\\")
        .replace("\t", "\\t")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )


def write_copy_header(f, table, columns):
    f.write(f"COPY {table} ({', '.join(columns)}) FROM stdin;\n")


def write_copy_row(f, *values):
    escaped = [escape_copy(v) for v in values]
    f.write("\t".join(escaped) + "\n")


def write_copy_footer(f):
    f.write("\\.\n\n")


def generate_dates(f):
    columns = [
        "id",
        "date",
        "year",
        "month",
        "day",
        "week_day",
        "quarter",
        "month_name",
        "week_day_name",
        "active_competitions",
    ]
    write_copy_header(f, "Date", columns)

    current = datetime(2023, 1, 1)
    for _ in range(N_DATES):
        date_val = current.strftime("%Y-%m-%d")
        date_id = int(current.strftime("%Y%m%d"))

        year = current.year
        month = current.month
        day = current.day
        weekday = current.weekday() + 1
        quarter = (month - 1) // 3 + 1
        month_name = current.strftime("%B")
        weekday_name = current.strftime("%A")

        active_series = sorted(date2series.get(date_id, []))
        if active_series:
            active_comps_str = "{" + ",".join(f'"{s}"' for s in active_series) + "}"
        else:
            active_comps_str = r"\N"  

        write_copy_row(
            f,
            date_id,
            date_val,
            year,
            month,
            day,
            weekday,
            quarter,
            month_name,
            weekday_name,
            active_comps_str,
        )
        current += timedelta(days=1)
    write_copy_footer(f)


def generate_participants(f):
    columns = ["id", "name", "country", "is_team", "meta"]
    write_copy_header(f, "Participant", columns)

    for pid in range(1, N_PARTICIPANTS + 1):
        is_team = random.random() < 0.1
        country = random.choice(countries)

        if is_team:
            name = f"Team {pid}"
            roster = []
            for _ in range(random.randint(5, 12)):
                fn, ln = random.choice(first_names), random.choice(last_names)
                dob = random_date_str(1980, 2005)
                roster.append(
                    {
                        "name": f"{fn} {ln}",
                        "role": random.choice(["Captain", "Player"]),
                        "date_of_birth": dob,
                        "email": f"{fn.lower()}.{ln.lower()}@gmail.com",
                        "password_hash": "sha256:fake",
                    }
                )
            meta = {"type": "Team", "roster": roster}
        else:
            fn, ln = random.choice(first_names), random.choice(last_names)
            name = f"{fn} {ln}"
            meta = {
                "type": "Athlet",
                "date_of_birth": random_date_str(1970, 2005),
                "email": f"{fn.lower()}.{ln.lower()}@gmail.com",
                "password_hash": "sha256:fake",
            }
        write_copy_row(
            f, pid, name, country, is_team, json.dumps(meta, ensure_ascii=False)
        )
    write_copy_footer(f)


def generate_competitions(f):
    
    columns = ["id", "series", "event", "matchup", "planner", "venue", "meta"]
    write_copy_header(f, "Competition", columns)

    for cid in range(1, N_COMPETITIONS + 1):
        date_id = random.choice(ALL_DATES)
        competition2date[cid] = date_id

        base_series = random.choice(series_list)
        series = f"{base_series} {str(date_id)[:4]}"  

        date2series[date_id].add(base_series)

        series = random.choice(series_list) + " " + str(random.randint(2023, 2025))
        event = random.choice(events_list)
        matchup = "TBD"
        venue = random.choice(venues_list)
        discipline = random.choice(sports)

        meta = {
            "discipline": discipline,
            "unit": "points" if discipline == "esports" else "meters",
            "result_format": random.choice(["best_of_3", "single_match"]),
        }
        if discipline in ["football", "basketball", "esports"]:
            meta["team_constraints"] = {
                "min_members": random.randint(2, 5),
                "max_members": random.randint(6, 12),
            }

        planner = [random.choice(first_names) for _ in range(random.randint(1, 3))]
        planner_str = "{" + ",".join(f'"{p}"' for p in planner) + "}"

        write_copy_row(
            f,
            cid,
            series,
            event,
            matchup,
            planner_str,
            venue,
            json.dumps(meta, ensure_ascii=False),
        )

    write_copy_footer(f)


def generate_outcomes(f):
    columns = ["id", "result_status", "outcome_status", "meta"]
    write_copy_header(f, "Outcome", columns)

    for oid in range(1, N_OUTCOMES + 1):
        result_status = random.choice(['Provisional', 'Official', 'Disputed', 'Canceled'])
        if random.random() < 0.05:
            outcome_status = "Disqualified"
            meta = {
                "context_type": "Disqualification",
                "disqualification_code": random.choice(disq_codes),
                "reason": "Rule violation",
            }
        else:
            outcome_status = random.choice(["Winner", "Runner-up", "Participant"])
            meta = {
                "context_type": "MatchConditions",
                "weather_conditions": {
                    "temperature_c": random.randint(-10, 40),
                    "precipitation": random.choice(["None", "Light Rain", "Snow"]),
                },
                "note": "Standard match",
            }
        write_copy_row(
            f, oid, result_status, outcome_status, json.dumps(meta, ensure_ascii=False)
        )

    write_copy_footer(f)


def generate_performances(f):
    columns = [
        "performance_id",
        "date_id",
        "competition_id",
        "participant_id",
        "outcome_id",
        "has_won",
        "prize_won",
        "registration_fee",
        "final_score_value",
    ]
    write_copy_header(f, "Performance", columns)

    date_ids = [
        int((datetime(2023, 1, 1) + timedelta(days=d)).strftime("%Y%m%d"))
        for d in range(N_DATES)
    ]

    for perf_id in range(1, N_PERFORMANCES + 1):
        date_id = random.choice(date_ids)
        participant_id = random.randint(1, N_PARTICIPANTS)
        competition_id = random.randint(1, N_COMPETITIONS)
        outcome_id = random.randint(1, N_OUTCOMES)
        has_won = random.random() < 0.3
        prize_won = f"{random.randint(100, 100000)}.00"
        registration_fee = f"{random.randint(10, 5000)}.00"
        final_score_value = str(random.randint(0, 100))

        write_copy_row(
            f,
            perf_id,
            date_id,
            competition_id,
            participant_id,
            outcome_id,
            has_won,
            prize_won,
            registration_fee,
            final_score_value,
        )
        if perf_id % 10_000_000 == 0:
            print(f"Performance: {perf_id} / {N_PERFORMANCES}")

    write_copy_footer(f)


def random_date_str(year_from, year_to):
    year = random.randint(year_from, year_to)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    return f"{year:04d}-{month:02d}-{day:02d}"

output2gen = {
    COMPETITIONS_SQL: generate_competitions,
    DATE_SQL: generate_dates,
    PARTICIPANTS_SQL: generate_participants,
    OUTCOME_SQL: generate_outcomes,
    PERFORMANCE_SQL: generate_performances
}

def main():
    for output, gen in output2gen.items():
        with open(output, "w", encoding="utf-8") as f:
            gen(f)
    # with open(OUTCOME_SQL, "w", encoding="utf-8") as f:
    #     generate_outcomes(f)

if __name__ == "__main__":
    main()
