<?php

namespace App\Http\Controllers;

use App\Models\Candidato;
use App\Models\Vaga;
use Illuminate\Http\Request;

class CandidatoController extends Controller
{
    public function index(Request $r)
    {
        $q       = trim((string) $r->query('q', ''));
        $sort    = (string) $r->query('sort', 'id');
        $dir     = strtolower((string) $r->query('dir', 'asc')) === 'desc' ? 'desc' : 'asc';
        $perPage = (int) $r->query('per_page', 20);

        $allowed = ['id','nome','email','created_at'];
        if (!in_array($sort, $allowed, true)) $sort = 'id';
        if ($perPage <= 0 || $perPage > 200) $perPage = 20;

        $qbuilder = Candidato::with('vagas:id,titulo');

        if ($q !== '') {
            $qbuilder->where(function($w) use ($q) {
                $w->where('nome','like',"%{$q}%")
                  ->orWhere('email','like',"%{$q}%");
            });
        }

        return $qbuilder->orderBy($sort,$dir)->paginate($perPage);
    }

    public function store(Request $r)
    {
        $data = $r->validate([
            'nome'     => 'required|string|max:255',
            'email'    => 'required|email|unique:candidatos,email',
            'vaga_ids' => 'array',
            'vaga_ids.*' => 'integer|exists:vagas,id',
        ]);

        $ids = collect($data['vaga_ids'] ?? []);
        $validos = Vaga::whereIn('id', $ids)->where('status','ativa')->pluck('id');
        if ($ids->diff($validos)->isNotEmpty()) {
            return response()->json(['message' => 'Há vagas pausadas nesta seleção.'], 422);
        }

        $cand = Candidato::create($data);
        if ($validos->count()) $cand->vagas()->sync($validos);
        return response()->json($cand->load('vagas:id,titulo'), 201);
    }

    public function show(Candidato $candidato)
    {
        return $candidato->load('vagas:id,titulo');
    }

    public function update(Request $r, Candidato $candidato)
    {
        $data = $r->validate([
            'nome'     => 'sometimes|required|string|max:255',
            'email'    => 'sometimes|required|email|unique:candidatos,email,'.$candidato->id,
            'vaga_ids' => 'sometimes|array',
            'vaga_ids.*' => 'integer|exists:vagas,id',
        ]);

        $candidato->update($data);

        if ($r->has('vaga_ids')) {
            $ids = collect($data['vaga_ids'] ?? []);
            $validos = Vaga::whereIn('id', $ids)->where('status','ativa')->pluck('id');
            $candidato->vagas()->sync($validos);
        }

        return $candidato->load('vagas:id,titulo');
    }

    public function destroy(Candidato $candidato)
    {
        $candidato->delete();
        return response()->noContent();
    }
}
