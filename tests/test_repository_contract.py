from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_field_data_is_present() -> None:
    expected = [
        ROOT / "data/jemerg24-realTime/metadata.yaml",
        ROOT / "data/jemerg24-realTime/rosbag2_2024_06_14-09_04_54_0.db3",
        ROOT / "data/jemerg24-filtered/metadata.yaml",
        ROOT / "data/jemerg24-filtered/jemerg24-filtered_0.db3",
    ]
    assert all(path.is_file() for path in expected)


def test_critical_algorithm_settings() -> None:
    solver = (ROOT / "src/osa_roud/ros_nodes/multilateration_for_OSA.py").read_text()
    median = (ROOT / "src/osa_roud/ros_nodes/FX8_medianBoth.py").read_text()
    analysis = (ROOT / "analysis/analysis_tool.py").read_text()

    assert "compute_position(\n            'Huber'" in solver
    assert solver.count("CircularBuffer(40)") >= 2
    assert "mobile_key = str(id_mobile)" in solver
    assert "window_size = 20" in median
    assert "geodesic((lat, lon), (gt.lat, gt.lon)).meters" in analysis
    assert 'default=10.0' in analysis


def test_analysis_defaults_are_repository_relative() -> None:
    analysis = (ROOT / "analysis/analysis_tool.py").read_text()
    assert "REPOSITORY_ROOT / \"data\" / \"jemerg24-realTime\"" in analysis
    assert "REPOSITORY_ROOT / \"data\" / \"jemerg24-filtered\"" in analysis
